# 2016-01-09
# Injabie3
#
# Description:
# PowerShell Robocopy script with e-mail notification
# Created by Michel Stevelmans - http://www.michelstevelmans.com
# Modified by Injabie3 - https://injabie3.moe

# Fetch settings
."$PSScriptRoot\vhd-hyperv-settings.ps1"


# Include the Discord helpers
# TODO move these.
."D:\Scripts\Helpers\Discord-Webhook.ps1"
."D:\Scripts\Helpers\Discord-Webhook-SFUAnime.ps1"

# Safely shut down the Virtual Machines
echo "======================================================================="
echo "= Lui's Backup Script - Hyper-V: Manual Backup                        ="
echo "======================================================================="
echo "= This script will backup the Virtual machines on this server.        ="
echo "======================================================================="

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Turning off VMs..."
Discord-PostWebhook-SFUAni "$($DiscordTitle)" `
    ":information_source: Ren will be shutting down momentarily..."

# Stop the Virtual Machines.
$VMsOff.ForEach({ Stop-VM -Name "$_" })

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: VMs are now turned off. Starting backups.."
Discord-PostWebhook-SFUAni "$($DiscordTitle)" `
    ":information_source: Ren is currently offline. Starting backups..."

# Back up to main destination first.
Robocopy $SourceFolder $DestinationMain[1] /E /ZB /R:10 /W:30 /LOG:$Logfile /TEE /NP

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Phase 1 complete, restarting VMs..."
Discord-PostWebhook-SFUAni "$($DiscordTitle)" `
    ":information_source: Backups have completed. Ren should restart momentarily..."
Add-Content $Logfile "`r`nBackup Phase 1 completed.`r`n"

if($RestartWID) {
    echo "Restarting Windows Internal Database to free up memory..."
    Add-Content $Logfile "Restarting Windows Internal Database to free up memory...`r`n"
    Restart-Service -DisplayName "Windows Internal Database"
}

Add-Content $Logfile "Starting up virtual machines...`r`n"

# Start up the Virtual Machines again, but stagger the startup times.
foreach($vm in $VMsOn) {
    Add-Content $Logfile "Booting up $($vm)"
    Start-VM -Name $vm
    Timeout 30
}

# Local Backups
foreach( $dest in $DestinationsLocal ) {
    Add-Content $Logfile "Backing up to $($dest[0])`r`n"
    Discord-PostWebhook "$($DiscordTitle)" `
        ":information_source: Backing up to $($dest[0])..."
    Robocopy $DestinationMain[1] $dest[1] /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP
}

# Remote Backups
foreach( $dest in $DestinationsRemote ) {
    Add-Content $Logfile "Backing up to $($dest[0])`r`n"
    Discord-PostWebhook "$($DiscordTitle)" `
        ":information_source: Backing up to $($dest[0])..."
    # When backing up over the network, do not use z flag or else we take a long
    # time to back up over network.
    Robocopy $DestinationMain[1] $dest[1] /E /B /R:10 /W:30 /LOG+:$Logfile /TEE /NP
}

# Prep the email to be sent.
$LogfileContents = Get-Content $Logfile | Out-String
$EmailBodyComplete = "<pre style=""font-size:11px"">" + $LogfileContents + "</pre>"

# Append to continuous log
Add-Content $LogfileAppend $LogfileContents

# Send E-mail message with log file attachment
$Message = New-Object `
    Net.Mail.MailMessage($EmailFrom, $EmailTo1, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $true
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object `
    System.Net.NetworkCredential($Username, $Password);
$SMTPClient.Send($Message)

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Backups are complete. The report was sent to $($EmailTo)."
