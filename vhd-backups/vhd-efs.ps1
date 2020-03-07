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
."D:\Scripts\Helpers\Discord-Webhook.ps1"

# Change these values
$BackupDate = Get-Date -format "yyyy-MM-dd"
$SourceFolder = "G:\EFS"
$DestinationFolder1 = "H:\Backups\EFS\$BackupDate" #2TB
$DestinationFolder2 = "I:\Backups\EFS\$BackupDate" #3TB
$DestinationFolder3 = "E:\Backups\EFS\$BackupDate" #RAID mirror
$Logfile = "G:\Logs\EFSCopy-Last.txt"
$LogfileAppend = "G:\Logs\EFSCopy.txt"
$EmailFrom = "no-reply@injabie3.tk"
$EmailTo = "sysadmin@injabie3.tk"

$ComputerName = (Get-CIMInstance CIM_ComputerSystem).Name
$EmailSubject = "${ComputerName}: Weekly Backup Log - EFS: $BackupDate"
$Username = "no-reply@injabie3.tk"
$Password = "<password here>"

Discord-PostWebhook -title "Monthly Backups" -message ":information_source: The scheduled VHD monthly backups have started. Dismounting VHDs..."

#Dismount the VHDs
."D:\Scripts\VHD-Dismount.ps1"

# Copy Folder with Robocopy
Robocopy $SourceFolder $DestinationFolder1 /E /ZB /R:10 /W:30 /LOG:$Logfile /TEE /NP
Robocopy $SourceFolder $DestinationFolder2 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP
Robocopy $SourceFolder $DestinationFolder3 /E /ZB /R:10 /W:30 /LOG+:$Logfile /TEE /NP

#Mount the VHDs again
."D:\Scripts\VHD-Mount.ps1"

#Prep the email to be sent.
$LogfileContents = Get-Content $Logfile | Out-String
$EmailBodyComplete = "<pre style=""font-size:14px"">" + $LogfileContents + "</pre>"

#Append to continuous log
Add-Content $LogfileAppend $LogfileContents

# Send E-mail message with log file attachment
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $true
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$SMTPClient.Send($Message)

Discord-PostWebhook -title "Monthly Backups" -message ":information_source: VHD backups are now complete. The status report was sent to `sysadmin@injabie3.tk`."
