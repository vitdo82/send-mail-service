#!/bin/bash
set -e

echo "Start entrypoint ..."
# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!" >&2
    exit 1
fi


# Set hostname dynamically (modify this if needed)
if [ -z "$MAIL_HOSTNAME" ]; then
    MAIL_HOSTNAME="smtp.vitdo.com"
fi

# Set the container's hostname (without modifying /etc/hosts)
#hostname "$MAIL_HOSTNAME"

echo "Configure Sendmail to listen on all interfaces ..."
#echo "define('confDOMAIN_NAME', '$MAIL_HOSTNAME')dnl" > /etc/mail/local-host-names
# echo "DAEMON_OPTIONS('Port=smtp,Addr=0.0.0.0, Name=MTA')dnl" >> /etc/mail/sendmail.mc
# m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

echo "Start send-mail-server ..."
./send-mail-server &

echo "Start sendmail ..."
sendmail -bd -q15m

echo "Run email test ..."
echo "Subject: sendmail test" | sendmail -v 7825134@gmail.com

#CMD /usr/lib/sendmail -bD -X /proc/self/fd/1 & npm start

# send-mail.vitdo.com ./send-mail-server &