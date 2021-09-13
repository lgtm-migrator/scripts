# 2021-09-12
# Injabie3
#
# Description:
# OpenVPN Server Login Notifier

# Fetch settings
."$PSScriptRoot\login-email-settings.ps1"

# Send E-mail message with the incoming connection info
$EmailBodyComplete = @"
Certificate CN: $Env:common_name
Connected to: $ComputerName
Origin: $Env:untrusted_ip
Timestamp: $Env:time_ascii
"@

$Message = New-Object `
    Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodyComplete)
$Message.IsBodyHtml = $false
$SMTPClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object `
    System.Net.NetworkCredential($Username, $Password);
$SMTPClient.Send($Message)
