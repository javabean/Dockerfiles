#!/bin/sh

# Generate a private and public key pair for use when signing your mail of a new DKIM domain
# http://www.opendkim.org/opendkim-README


# Choose a selector name.  A selector is simply a symbolic name given to
# a key you will be using to sign your mail.  You are free to choose any
# name you wish.  One current convention if you are using multiple
# mailservers is to use the hostname (hostname only, not the fully-qualified
# domain name) of the host that will be providing the service.  Another 
# convention is to use the current month and year.
SELECTOR=${SELECTOR:-mail}
# Use '--subdomains' to allow signing of subdomains
SIGN_SUBDOMAINS=${SIGN_SUBDOMAINS:-}
# Use '-t' or '--testmode' for "test mode", advising verifiers that they
# should not take any real action based on success or failure of the use
# of this key after verifing a message.  Remove the "t=y" once you have
# tested the DKIM signing of your messages to your satisfaction.
# You might want to set a short TTL on this record during testing so
# changes are propagated to other nameservers more quickly.
TEST_MODE=${TEST_MODE:-}
# Domain we want to sign mail for
DOMAIN=${DOMAIN:-example.net}
# Who should we sign mail for this domain? Use '*' for everyone.
SENDERS=${SENDERS:-*}

opendkim-genkey -r -s ${SELECTOR} ${TEST_MODE} ${SIGN_SUBDOMAINS} -D /usr/local/etc/dkim/keys/${DOMAIN}/ --domain=${DOMAIN}
chown opendkim:postfix /usr/local/etc/dkim/keys/${DOMAIN}/${SELECTOR}.*
chmod 0600 /usr/local/etc/dkim/keys/${DOMAIN}/${SELECTOR}.private
chmod 0700 /usr/local/etc/dkim/keys/${DOMAIN}

echo "${SENDERS}@${DOMAIN}\t${SELECTOR}._domainkey.${DOMAIN}" >> /usr/local/etc/dkim/SigningTable

echo "${SELECTOR}._domainkey.${DOMAIN}\t${DOMAIN}:${SELECTOR}:/usr/local/etc/dkim/keys/${DOMAIN}/${SELECTOR}.private" >> /usr/local/etc/dkim/KeyTable

echo "Insert the following TXT resource record in your DNS zone file ${SELECTOR}._domainkey.${DOMAIN}"
cat /usr/local/etc/dkim/keys/${DOMAIN}/${SELECTOR}.txt

echo "Once published, you can test with `opendkim-testkey -d ${DOMAIN} -s ${SELECTOR} -k /usr/local/etc/dkim/keys/${DOMAIN}/${SELECTOR}.private`"
