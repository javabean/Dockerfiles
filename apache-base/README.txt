Base Apache httpd image

Can run
	/usr/local/bin/backup_conf_local.sh
while building Docker image, if you call (in sub-image Dockerfile)
	RUN /usr/local/bin/backup_conf.sh

Will run
	/usr/local/bin/restore_conf_local.sh
before starting Apache
