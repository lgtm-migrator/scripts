# Login Email
## Description
Send email notifications whenever someone logs into your system. Requires `mail` to
be installed on the system, and modifications to PAM.

## Usage
This assumes you already have `mail` configured.
1. Copy the script to a path executable by root.
2. Modify the script variables to your email addresses.
3. Add the following line to `/etc/pam.d/sshd`:

```
# Send login emails to sysadmin
session optional pam_exec.so seteuid /path/to/login-email.sh
```
4. Restart sshd.
5. Login and test.
