#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# need bash (not sh) for 'read' options...

newclient () {
	CLIENT_CERT="./clients/$1.ovpn"
	# Generates the custom client.ovpn
	cp client-common.txt ${CLIENT_CERT}
	echo "<dh>"             >> "${CLIENT_CERT}"
	cat easy-rsa/pki/dh.pem >> "${CLIENT_CERT}"
	echo "</dh>"            >> "${CLIENT_CERT}"
	echo "<ca>"             >> "${CLIENT_CERT}"
	cat easy-rsa/pki/ca.crt >> "${CLIENT_CERT}"
	echo "</ca>"            >> "${CLIENT_CERT}"
	echo "<cert>"           >> "${CLIENT_CERT}"
	cat easy-rsa/pki/issued/$1.crt >> "${CLIENT_CERT}"
	echo "</cert>"          >> "${CLIENT_CERT}"
	echo "<key>"            >> "${CLIENT_CERT}"
	cat easy-rsa/pki/private/$1.key >> "${CLIENT_CERT}"
	echo "</key>"           >> "${CLIENT_CERT}"
	echo "<tls-crypt>"      >> "${CLIENT_CERT}"
	cat ta.key              >> "${CLIENT_CERT}"
	echo "</tls-crypt>"     >> "${CLIENT_CERT}"
}

if [ "$#" -eq 0 ]; then
	echo ""
	echo "Tell me a name for the client cert."
	echo "Please, use one word only, no special characters."
	read -p "Client name: " -e CLIENT
    set -- "$CLIENT" "$@"
fi

while test "$#" -gt 0; do
	echo "Generating client certificate for: $1"
	cd easy-rsa
	EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-client-full "$1" nopass
	cd ..
	# Generates the custom client.ovpn
	newclient "$1"
	echo ""
	echo "Client $1 added, certs available at: ./clients/$1.ovpn"
	shift
done
