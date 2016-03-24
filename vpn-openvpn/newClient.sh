#!/bin/bash

# need bash (not sh) for 'read' options...

newclient () {
	CLIENT_CERT="./clients/$1.ovpn"
	# Generates the custom client.ovpn
	cp client-common.txt ${CLIENT_CERT}
	echo "<dh>"             >> ${CLIENT_CERT}
	cat easy-rsa/pki/dh.pem >> ${CLIENT_CERT}
	echo "</dh>"            >> ${CLIENT_CERT}
	echo "<ca>"             >> ${CLIENT_CERT}
	cat easy-rsa/pki/ca.crt >> ${CLIENT_CERT}
	echo "</ca>"            >> ${CLIENT_CERT}
	echo "<cert>"           >> ${CLIENT_CERT}
	cat easy-rsa/pki/issued/$1.crt >> ${CLIENT_CERT}
	echo "</cert>"          >> ${CLIENT_CERT}
	echo "<key>"            >> ${CLIENT_CERT}
	cat easy-rsa/pki/private/$1.key >> ${CLIENT_CERT}
	echo "</key>"           >> ${CLIENT_CERT}
	echo "<tls-auth>"       >> ${CLIENT_CERT}
	cat ta.key              >> ${CLIENT_CERT}
	echo "</tls-auth>"      >> ${CLIENT_CERT}
}

echo ""
echo "Tell me a name for the client cert"
echo "Please, use one word only, no special characters"
read -p "Client name: " -e -i client CLIENT
cd easy-rsa
./easyrsa build-client-full "$CLIENT" nopass
cd ..
# Generates the custom client.ovpn
newclient "$CLIENT"
echo ""
echo "Client $CLIENT added, certs available at ./clients/$CLIENT.ovpn"
