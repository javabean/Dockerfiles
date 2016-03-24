VPN (OpenVPN) server

Mount /etc/openvpn as volume

To change generated certificates parameters, use env vars: https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md


https://community.openvpn.net/openvpn/wiki/HOWTO
https://community.openvpn.net/openvpn/wiki/FAQ
https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage


Requires host's /lib/modules mounted (read-only!) in order to
	modprobe tun


Known issue: no separation between CA management and vpn server
