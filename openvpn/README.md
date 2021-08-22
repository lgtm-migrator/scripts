# OpenVPN .ovpn Generator
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

## Usage
1. Run the easy-rsa set up (assuming you are configuring this on a Windows-based
   system), generating the necessary CA, TLS auth key, and client files. Client files
   should be prefixed by their hostnames that you have while running the `build-key`
   batch file.
2. Copy all files into the same directory as this script.
3. Make a copy of the settings file, and tweak the variables to match your needs.
4. Run the script for each client you have to generate the `.ovpn` profile.
5. Copy the profiles onto your devices.
6. Connect to your VPN as need be.
