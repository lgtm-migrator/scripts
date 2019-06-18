#!/usr/bin/env bash
# 2019-01-04
# Injabie3
#
# Description:
# Login Email Notifications
# Get an email alert whenever someone logs into the system via SSH
#

hostname=`hostname`
body="User: $PAM_USER\nConnected to: $hostname\nOrigin: $PAM_RHOST\nTimestamp: `date`\nPrevious Login: `lastlog | grep $PAM_USER`"
subject="$hostname: New Login for $PAM_USER"
recipient="SysAdmin <sysadmin@example.com>"
fromUser="Name <email@example.com>"
if [ "$PAM_TYPE" != "close_session" ]; then
    echo -e $body | mail -s "$subject" "$recipient" -a "From: $fromUser" &
fi
