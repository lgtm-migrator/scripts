# 2016-01-09
# Injabie3
#
# Description:
# PowerShell Robocopy script with e-mail notification
# Created by Michel Stevelmans - http://www.michelstevelmans.com
# Modified by Injabie3 - https://injabie3.moe

# Fetch settings
."$PSScriptRoot\vhd-efs-settings.ps1"

# Include the Discord helpers
."D:\Scripts\Helpers\Discord-Webhook.ps1"

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Dismounting VHDs..."
$VHDDismount.ForEach( { Dismount-VHD -Path "$($_[1])" } )
Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: VHDs are dismounted. Starting backups.."

Robocopy $SourceFolder $DestinationMain[1] /E /ZB /R:10 /W:30 /LOG:$Logfile /TEE /NP

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Phase 1 complete, remounting VHDs..."
$VHDDismount.ForEach( { Mount-VHD -Path "$($_[1])" } )

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
    Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $true
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object `
    System.Net.NetworkCredential($Username, $Password);
$SMTPClient.Send($Message)

Discord-PostWebhook "$($DiscordTitle)" `
    ":information_source: Backups have completed. The report was sent to $($EmailTo)."
