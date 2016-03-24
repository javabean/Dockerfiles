IMAP Dovecot server with local (non-system) users only

Put configuration in /opt/dovecot/local.conf (or mount /etc/dovecot/local.conf file)
Put local users in /opt/dovecot/passwd (or mount /etc/dovecot/users file)

First run will take a bit of time while generating DH parameters. Subsequent runs will be much faster.
You can mount a pre-computed /var/lib/dovecot/ssl-parameters.dat to avoid this.
