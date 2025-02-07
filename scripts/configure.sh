#!/bin/bash

# Define domains
DOMAINS=("domain1.com" "domain2.com" "domain3.com")

# Update local-host-names
echo "Updating local-host-names..."
echo "${DOMAINS[@]}" > /etc/mail/local-host-names

# Configure virtual user table
echo "Configuring virtual user table..."
cat <<EOF > /etc/mail/virtusertable
vitdo@send-mail.vitdo.com   vitdo
@send-mail.vitdo.com        vitdo
EOF

# Convert virtusertable to database format
echo "Generating virtusertable.db..."
makemap hash /etc/mail/virtusertable < /etc/mail/virtusertable

# Update sendmail.mc
echo "Updating sendmail.mc..."
TMPFILE=$(mktemp)
awk '/MAILER\(/ { print "FEATURE('virtusertable', 'hash -o /etc/mail/virtusertable.db')dnl"; done=1 } { print } END { if (!done) print "FEATURE('virtusertable', 'hash -o /etc/mail/virtusertable.db')dnl" }' /etc/mail/sendmail.mc > "$TMPFILE" && mv "$TMPFILE" /etc/mail/sendmail.mc

cat /etc/mail/sendmail.mc

#cat <<EOF >> /etc/mail/sendmail.mc
#FEATURE('virtusertable', 'hash -o /etc/mail/virtusertable.db')dnl
#EOF

# Rebuild sendmail.cf
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

# Restart Sendmail service using the available method
echo "Restarting Sendmail service..."
if command -v systemctl &> /dev/null; then
    systemctl restart sendmail
elif command -v service &> /dev/null; then
    service sendmail restart
else
    echo "Error: Neither systemctl nor service command found!" >&2
    exit 1
fi

# Verify setup
echo "Configuration completed. Checking status..."
if command -v systemctl &> /dev/null; then
    systemctl status sendmail --no-pager
elif command -v service &> /dev/null; then
    service sendmail status
else
    echo "Error: Unable to check Sendmail status."
fi
