# OpenVPN Scripts
This directory contains the following OpenVPN scripts, which are to be used on a
Windows-based deployment:
- [Profile Generator](#profile-generator)
- [client-connect Email Notifier](#client-connect-email-notifier)

## Profile Generator
This script allows you to quickly generate the .ovpn profiles needed to connect to
your own OpenVPN server. It stitches together the following files using common
configuration stored in a templated ovpn file:
- The server and port to connect to.
- Common certificate authority (CA).
- Common TLS auth key.
- Client-specific certificate.
- Client-specific private key.

In my use case, I'm not redirecting all traffic through the VPN, but only using it
to access resources on my private network.

Feel free to adjust as you see fit.

### Usage
1. Run the easy-rsa set up (assuming you are configuring this on a Windows-based
   system), generating the necessary CA, TLS auth key, and client files. Client files
   should be prefixed by their hostnames that you have while running the `build-key`
   batch file.
2. Copy all files into the same directory as this script.
3. Make a copy of the settings file, and tweak the variables to match your needs.
4. Run the script for each client you have to generate the `.ovpn` profile.
5. Copy the profiles onto your devices.
6. Connect to your VPN as need be.

## client-connect Email Notifier
This script sends an Email notification to a specified email address when a user
successfully connects to your OpenVPN server.

### Usage
1. Create a batch file with the following contents:

On a Windows Server R2 2012 system (with Powershell 2.0):
```bat
C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe ^
 -ExecutionPolicy Bypass ^
 -File C:\path\to\script\login-email.ps1
```
On systems with newer PowerShell:
```bat
C:\Program Files\WindowsPowershell\powershell.exe ^
 -ExecutionPolicy Bypass ^
 -File C:\path\to\script\login-email.ps1
```

2. In your OpenVPN server configuration profile, add the following lines:
```
# This allows user-defined scripts
script-security 2

# Call our script when a client connects.
client-connect "C:\\Path\\To\\Batch\\Script.bat"
```

3. Create a copy of `login-email-settings.ps1.sample`, and then rename it to
   `login-email-settings.ps1`
4. Edit the email configuration to your needs.
5. Restart your OpenVPN server.
