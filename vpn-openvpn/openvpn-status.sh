#!/bin/sh

# "env" needed in order to get the binary "kill" instead of built-in which does not know a thing about SIGsignals...
#env kill -s SIGUSR2 `cat /run/openvpn/server.pid`
kill -s USR2 `cat /run/openvpn/server.pid`
echo "connection statistics outputed to log file or syslog"