# 2016-01-09
# Injabie3
#
# Description:
# PowerShell Robocopy script with e-mail notification
# Created by Michel Stevelmans - http://www.michelstevelmans.com
# Modified by Injabie3 - https://injabie3.moe

# Fetch settings
.".\vhd-hyperv-settings.ps1"


# Include the Discord helpers
# TODO move these.
."D:\Scripts\Helpers\Discord-Webhook.ps1"
."D:\Scripts\Helpers\Discord-Webhook-SFUAnime.ps1"
."D:\Scripts\Helpers\Discord-Webhook-VANime.ps1"

# Safely shut down the Virtual Machines
echo "======================================================================="
echo "= Lui's Backup Script - Hyper-V: Manual Backup                        ="
echo "======================================================================="
echo "= This script will backup the Virtual machines on this server.        ="
echo "======================================================================="

Discord-PostWebhook "Monthly Backups" ":information_source: Testing new script, please ignore."
# Discord-PostWebhook-SFUAni "Monthly Backups" ":information_source: Ren will be shutting down momentarily..."
# Discord-PostWebhook-VANime "Monthly Backups" ":information_source: Kanbi will be shutting down momentarily..."

# Stop the Virtual Machines.
# TODO move VM names to settings file.
#Stop-VM -Name "LuiV-Azuki"
#Stop-VM -Name "LuiV-DC2" -Force
#Stop-VM -Name "LuiV-GitLab"
#Stop-VM -Name "LuiV-Silica"
#Stop-VM -Name "LuiV-Testing"

Discord-PostWebhook "Monthly Backups" ":information_source: VMs are now turned off.  Starting backups.."
# Discord-PostWebhook-SFUAni "Monthly Backups" ":information_source: Ren is currently offline.  Starting backups..."
# Discord-PostWebhook-VANime "Monthly Backups" ":information_source: Kanbi is currently offline.  Starting backups..."

### BACKUP PHASE 1 ###
# Backup to RAID Mirror first.
# Robocopy $SourceFolder $DestinationRAID /E /ZB /R:10 /W:30 /LOG:$Logfile /TEE /NP

Discord-PostWebhook "Monthly Backups" ":information_source: Phase 1 of backups complete (RAID)."
# Discord-PostWebhook-SFUAni "Monthly Backups" ":information_source: The scheduled monthly backups have completed.  Ren will restart momentarily..."
# Discord-PostWebhook-VANime "Monthly Backups" ":information_source: The scheduled monthly backups have completed.  Kanbi will restart momentarily..."

Add-Content $Logfile "`r`nBackup Phase 1 completed, starting up virtual machines...`r`n"

### VM Reboot ###
# Start up the Virtual Machines again, but stagger the startup times.
Add-Content $Logfile "Booting up LuiV-Azuki"
# Start-VM -Name "LuiV-Azuki"
Add-Content $Logfile "[OK]`r`n"
Add-Content $Logfile "Timeout period...`r`n"

# TIMEOUT 30

Add-Content $Logfile "Booting up LuiV-Silca..."
# Start-VM -Name "LuiV-Silica"
Add-Content $Logfile "[OK]`r`n"
Add-Content $Logfile "Timeout period...`r`n"

# TIMEOUT 120

Add-Content $Logfile "Starting Backup Phase 2...`r`n"

Discord-PostWebhook "Monthly Backups" ":information_source: Starting phase 2 of backups (External HDDs)."

### BACKUP PHASE 2 ###
# Copy from the backup'd folder to other backup destinations.
#Robocopy $DestinationRAID $DestinationFolder1 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP
#Robocopy $DestinationRAID $DestinationFolder2 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP

Discord-PostWebhook "Monthly Backups" ":information_source: Starting phase 3 of backups (LuiP-Miria)."
# Robocopy $DestinationRAID $DestinationFileServer /E /B /R:10 /W:30 /LOG+:$Logfile /TEE /NP

# Prep the email to be sent.
$LogfileContents = Get-Content $Logfile | Out-String
$EmailBodyComplete = "<pre style=""font-size:14px"">" + $LogfileContents + "</pre>"

# Append to continuous log
# Add-Content $LogfileAppend $LogfileContents

# Send E-mail message with log file attachment
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo1, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $true
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);

#Send email 1 to mailing list.
# $SMTPClient.Send($Message)
Discord-PostWebhook "Monthly Backups" ":information_source: Monthly backups are now complete.  The status report was sent to `$($EmailTo1)`."