#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

NUMBEROFCLIENTS=$(tail -n +2 easy-rsa/pki/index.txt | grep -c "^V")
if [ "$NUMBEROFCLIENTS" = '0' ]; then
	echo ""
	echo "You have no existing clients!"
	exit 6
fi
echo ""
echo "Select the existing client certificate you want to revoke"
tail -n +2 easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
if [ "$NUMBEROFCLIENTS" = '1' ]; then
	read -p "Select one client [1]: " CLIENTNUMBER
else
	read -p "Select one client [1-$NUMBEROFCLIENTS]: " CLIENTNUMBER
fi
CLIENT=$(tail -n +2 easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
cd easy-rsa/
./easyrsa --batch revoke "$CLIENT"
./easyrsa gen-crl
# Ensure "nobody" can read the CRL
chmod a+r pki/crl.pem
chmod a+x pki
rm -f "pki/reqs/$CLIENT.req"
rm -f "pki/private/$CLIENT.key"
rm -f "pki/issued/$CLIENT.crt"
cd ..
# And restart
#if pgrep systemd-journal; then
#	systemctl restart openvpn@server.service
#else
#	if [ "$OS" = 'debian' ]; then
#		/etc/init.d/openvpn restart
#	else
#		service openvpn restart
#	fi
#fi
# "env" needed in order to get the binary "kill" instead of built-in which does not know a thing about SIGsignals...
#env kill -s SIGUSR1 `cat /run/openvpn/server.pid`
kill -s USR1 `cat /run/openvpn/server.pid`
echo ""
echo "Certificate for client $CLIENT revoked"
