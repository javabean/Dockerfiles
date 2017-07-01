#!/bin/bash
#set -u
set -e -o pipefail -o posix
#shopt -s failglob
#set -x

# Starts a CQ / AEM instance with the following properties:
#
# * env vars passed-in via Docker, or declared in file /usr/local/etc/aem6
# * cq / aem jar is copied at build-time in `/opt/aem6/aem-*.jar` or `/opt/aem6/cq-*.jar` (see `AEM_JAR_URL`)
# * cq / aem install directory is `${CQ_BASEFOLDER:-/srv/aem6}`
# * cq / aem licence file is `${CQ_BASEFOLDER:-/srv/aem6}/license.properties`
# * cq / aem packages (SP / CFP / hotfixes / featurepacks / ...) to install at startup in `${PACKAGES_ROOT:-/opt/aem6/packages}`
#
# Packages will be installed 1 by 1 at startup (via HTTP API) in lexical order, and will be deleted when installed.
# To restart the AEM instance, simply input an empty file.
#
# Bonus: can also remove Geometrixx if `${REMOVE_GEOMETRIXX}` is set


load_and_check_vars() {
	DEFAULT=/usr/local/etc/aem6
	[ -r "$DEFAULT" ] && . $DEFAULT

	# Ensure root directory exists

	if [ -z "$CQ_BASEFOLDER" ]; then
		echo "No CQ_BASEFOLDER set. Please create and edit $DEFAULT (see documentation)."
		exit 1
	fi

	if [ ! -d "$CQ_BASEFOLDER" ]; then
		echo "The defined CQ root directory [$CQ_BASEFOLDER] does not exist."
		echo "Please make sure it points to a valid CQ6 root directory."
		echo "A valid root directory contains the AEM jar file, license.properties and crx-quickstart subfolder."
		echo "Please edit $DEFAULT accordingly."
		exit 1
	else
		CQ_QUICKSTART="$CQ_BASEFOLDER/crx-quickstart"
	fi

	START="${CQ_QUICKSTART}/bin/start"
	STOP="${CQ_QUICKSTART}/bin/stop"
	STATUS="${CQ_QUICKSTART}/bin/status"
	PIDFILE="$CQ_QUICKSTART/conf/cq.pid"

	# Those are env vars used by crx-quickstart/bin/start
	export CQ_PORT CQ_HOST CQ_RUNMODE CQ_JARFILE CQ_JVM_OPTS CQ_FILE_SIZE_LIMIT CQ_USE_JAAS CQ_JAAS_CONFIG CQ_MONGO_HOST CQ_MONGO_PORT CQ_MONGO_DB
}

unpack() {
	# First run: install AEM
	if [ ! -d "$CQ_BASEFOLDER/crx-quickstart" ]; then
		local CQ_JARFILE=$CQ_JARFILE
		if [ -z $CQ_JARFILE ]; then
			CQ_JARFILE=`ls -1 /opt/aem6/aem-*.jar | head -1`
		fi
		if [ -z $CQ_JARFILE ]; then
			CQ_JARFILE=`ls -1 /opt/aem6/cq-*.jar | head -1`
		fi
		START_OPTS="-unpack -nobrowser"
		if [ "$CQ_PORT" ]; then
			START_OPTS="${START_OPTS} -p ${CQ_PORT}"
		fi
		if [ "$CQ_VERBOSE" ]; then
			START_OPTS="${START_OPTS} -verbose"
		fi
		if [ "$CQ_RUNMODE" ]; then
			START_OPTS="${START_OPTS} -r ${CQ_RUNMODE}"
		fi
		if [ "$CQ_BASEFOLDER" ]; then
			START_OPTS="${START_OPTS} -b ${CQ_BASEFOLDER}"
		fi
		gosu "${CQ_USER}" java -jar "${CQ_JARFILE}" ${START_OPTS}
	fi
}

clean_tmp() {
	if [ ! -f "${PIDFILE}" ] ; then
		gosu "${CQ_USER}" rm -rf "${CQ_TMPDIR}/*"
	fi
}

start() {
	# Create tmp directory if it does not exist
	if [ ! -d "${CQ_TMPDIR}" ]; then
		gosu "${CQ_USER}" mkdir -p "${CQ_TMPDIR}"
	fi
	clean_tmp
	#/srv/crx-quickstart/bin/start
	# beware the "start" script forks...
	gosu "${CQ_USER}" "${START}" 2>&1 >> "$CQ_GCLOGDIR/startup.log"
}

status() {
	echo "Starting AEM instance..."
	#/srv/crx-quickstart/bin/status
	gosu "${CQ_USER}" "${STATUS}" 2>&1 >> "$CQ_GCLOGDIR/startup.log"
}

stop() {
	echo -n "Stopping AEM instance"
	#/srv/crx-quickstart/bin/stop
	gosu "${CQ_USER}" "${STOP}" 2>&1 >> "$CQ_GCLOGDIR/startup.log"
	# "$PIDFILE" will only disappear if AEM did not stop correctly(!)
	if [ -s "$PIDFILE" ]; then
		while [ `pgrep -c -F "${PIDFILE}"` -ne 0 ]; do
			sleep 1
			echo -n "."
		done
	fi
	echo
	rm "$PIDFILE"
	clean_tmp
}

shut_down() {
	stop
	exit
}

# Blocks until AEM is ready for service (i.e. is fully started)
wait_for_aem_startup() {
	url=$1
	instance_name=${2:-aem instance}
	local content_curl
	local result_curl
	local result_grep

	echo -n "Waiting for ${instance_name} startup"

	# Wait for open socket
	curl -s -o /dev/null -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"
	while [ $? -ne 0 ]; do
		sleep 2
		echo -n '.'
		curl -s -o /dev/null -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"
	done
	echo -n "S"

	# Wait for instance startup (404 on / while getting ready to start up)
	content_curl=`curl -s -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"`
	result_curl=$?
	echo "$content_curl" | grep -q "Problem accessing /. Reason:"
	result_grep=$?
	while [ $result_curl -ne 0 ] || [ $result_grep -eq 0 ]; do
		sleep 2
		echo -n '.'
		content_curl=`curl -s -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"`
		result_curl=$?
		echo "$content_curl" | grep -q "Problem accessing /. Reason:"
		result_grep=$?
	done
	echo -n "4"

	# Wait for instance ready
	content_curl=`curl -s -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"`
	result_curl=$?
	echo "$content_curl" | grep -q "Startup in progress"
	result_grep=$?
	while [ $result_curl -ne 0 ] || [ $result_grep -eq 0 ]; do
		sleep 2
		echo -n '.'
		content_curl=`curl -s -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" "${url}"`
		result_curl=$?
		echo "$content_curl" | grep -q "Startup in progress"
		result_grep=$?
	done
	echo -n "R"
	echo
}

# Blocks until AEM shows no log activity
wait_for_aem_quiescent() {
	server=${1:-localhost:4502}
	credentials=${2:-admin:admin}
	min_seconds=${3:-10}

	time_diff=0
	until [ $time_diff -gt $min_seconds ]
	do
		sleep 5
		# awk: grep the error.log file
		last_log_line=`curl -fsS -u "${credentials}" http://${server}/system/console/status-slinglogs.txt | awk '/^Log\ file\ /{p=0};p;/\/error\.log$/{p=1}' | tail -n 2 | head -1`
		last_log_date=`echo $last_log_line | sed -r 's/^([[:digit:]]{2})\.([[:digit:]]{2})\.([[:digit:]]{4}) ([[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}).*/\3-\2-\1 \4/'`
		time_diff=`expr $(date +%s) - $(date +%s -d "$last_log_date")`
		if [ $time_diff -gt 10000 ]; then
			# could probably not compute $last_log_date properly (e.g. last line of a stack trace)
			time_diff=0
		fi
		echo "${time_diff}s: $last_log_line"
	done
}

# Remove Geometrixx sample content
aem_remove_geometrixx() {
	server=${1:-localhost:4502}
	credentials=${2:-admin:admin}

	# http://${server}/crx/packmgr/list.jsp?cmd=ls
	geometrixx_path=`curl -u"${credentials}" -fsS "http://${server}/crx/packmgr/list.jsp?q=cq-geometrixx-all-pkg"|grep -o -e 'path":"[^"]*'|awk -F'"' '{print $3}'`
	if [ ! -z "${geometrixx_path}" ]; then
		echo -n "Removing ${server}${geometrixx_path}: "
		curl -fsS -u "${credentials}" -X POST http://${server}/crx/packmgr/service/.json${geometrixx_path}?cmd=uninstall
		echo && wait_for_aem_quiescent "${server}" "${credentials}" 10
		curl -fsS -u "${credentials}" -X POST http://${server}/crx/packmgr/service/.json${geometrixx_path}?cmd=delete
		echo && wait_for_aem_quiescent "${server}" "${credentials}" 5
	fi
}

# The "nosamplecontent" run mode disables CRXDE Lite.
# https://docs.adobe.com/docs/en/aem/6-2/administer/security/production-ready.html
# This method re-enables it.
# https://docs.adobe.com/docs/en/aem/6-2/administer/security/security-checklist/enabling-crxde-lite.html
enable_crxde_lite() {
	server=${1:-localhost:4502}
	credentials=${2:-admin:admin}
	echo "Enabling CRXDE Lite"
	curl -fsS -u "${credentials}" -F "jcr:primaryType=sling:OsgiConfig" -F "alias=/crx/server" -F "dav.create-absolute-uri=true" -F "dav.create-absolute-uri@TypeHint=Boolean" http://${server}/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet
}

install_packages() {
	server=${1:-localhost:4502}
	credentials=${2:-admin:admin}
	local return_code

	echo "Waiting for ${server} to become ready for service..."
	wait_for_aem_startup "${server}" "AEM instance"

	if [ ! -z "${REMOVE_GEOMETRIXX}" ]; then
		echo "Removing Geometrix on ${server}..." 
		aem_remove_geometrixx "${server}" "${credentials}"
	fi

	for package in `ls -1 "${PACKAGES_ROOT}"`; do

		if [ -s "${PACKAGES_ROOT}/${package}" ]; then
			echo "Uploading and installing ${package} on ${server}..."
			curl -fsS -u "${credentials}" -F file=@"${PACKAGES_ROOT}/${package}" -F force=true  -F install=true http://${server}/crx/packmgr/service.jsp
			return_code=$?
			if [ $return_code -ne 0 ]; then
				echo "WARNING: could not install package ${package}. Skipping all remaining packages installation."
				break
			fi
			echo
			echo "Waiting for AEM Quiescent..."
			echo && wait_for_aem_quiescent "${server}" "${credentials}" 10
			echo
			# The following will block if previous package installation fucked up the instance...
			wait_for_aem_startup "${server}" "AEM instance"
		else
			# empty "package" file: restart AEM instance
			echo "Restarting AEM instance..."
			stop
			start
			echo "Waiting for ${server} to become ready for service..."
			wait_for_aem_startup "${server}" "AEM instance"
		fi

		rm -v "${PACKAGES_ROOT}/${package}"

	done
}


trap "shut_down" HUP INT QUIT TERM

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- start "$@"
fi

# check for the expected command
if [ "$1" = 'start' ]; then

	load_and_check_vars

	# First run: install AEM
	unpack

	# Launch AEM
	start
	install_packages "localhost:${CQ_PORT}" "${CQ_AUTH}"

	# "start" script forks...
	# it seems we can't read from stdin here; default to eternal sleep...
	#read _
	#line
	while true; do sleep 999; done
	shut_down
	exit $0

fi

# else default to run whatever the user wanted like "bash"
exec "$@"





##############################################################################

exit

# Further reference:

cq_host_src=${1:-"localhost:4502"}
user_src=${2:-"admin:admin"}
cq_host_dst=${3:-"localhost:4503"}
user_dest=${4:-"admin:admin"}

# List all packages: http://${server}/crx/packmgr/list.jsp?cmd=ls
# Search for a package: http://${server}/crx/packmgr/list.jsp?q=cq-geometrixx-all-pkg
echo "Buiding package ${path}/${name} on ${cq_host_src}..."
curl -fsS -u "${user_src}" -X POST http://${cq_host_src}/crx/packmgr/service/.json/etc/packages/${path}/${name}?cmd=build
echo
echo "Waiting for AEM Quiescent..."
echo && wait_for_aem_quiescent "${cq_host_src}" "${user_src}" 10
echo
echo "Grabbing ${path}/${name} from ${cq_host_src}..."
curl -fsS -u "${user_src}" http://${cq_host_src}/etc/packages/${path}/${name} > /tmp/cq_packages/${name}
echo
echo "Uploading and installing ${name} on ${cq_host_dst}..."
curl -fsS -u "${user_dest}" -F file=@"/tmp/cq_packages/${name}" -F force=true  -F install=true http://${cq_host_dst}/crx/packmgr/service.jsp
echo
echo "Waiting for AEM Quiescent..."
echo && wait_for_aem_quiescent "${cq_host_dst}" "${user_dest}" 10
echo
echo "Uploading ${name} on ${cq_host_dst}..."
curl -fsS -u "${user_dest}" -F package=@"/tmp/cq_packages/${name}" -F force=true http://${cq_host_dst}/crx/packmgr/service/.json/?cmd=upload
echo
echo "Deleting ${name} on ${cq_host_src}..."
curl -fsS -u "${user_src}" http://${cq_host_src}/crx/packmgr/service/.json/etc/packages/${path}/${name}?cmd=delete
echo
echo "Waiting for AEM Quiescent..."
echo && wait_for_aem_quiescent "${cq_host_dst}" "${user_dest}" 10
echo
echo "Installing ${path}/${name} on ${cq_host_dst}..."
curl -fsS -u "${user_dest}" -X POST http://${cq_host_dst}/crx/packmgr/service/.json/etc/packages/${path}/${name}?cmd=install&recursive=true
echo 
echo "Waiting for AEM Quiescent..."
echo && wait_for_aem_quiescent "${cq_host_dst}" "${user_dest}" 10
echo
echo "Replicating ${path}/${name} on ${cq_host_dst}..."
curl -sSf -u "${user_dest}" -X POST http://${cq_host_dst}/crx/packmgr/service/.json/etc/packages/${path}/${name}?cmd=replicate
echo
echo "Waiting for AEM Quiescent..."
echo && wait_for_aem_quiescent "${cq_host_dst}" "${user_dest}" 10
echo
