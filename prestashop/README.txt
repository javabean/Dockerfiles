PrestaShop server

About same usage as https://hub.docker.com/r/prestashop/prestashop/ -- see restore_conf_local.sh for all available options
In particular, can rename "/admin" via $PS_FOLDER_ADMIN environment variable

To save your shop data, mount volumes in
	/var/www/html/.htaccess  (file)
	/var/www/html/override
	/var/www/html/mails
	/var/www/html/img
	/var/www/html/modules
	/var/www/html/download
	/var/www/html/upload
	/var/www/html/config

Exposes APC cache statistics on URL "/admin/apc.php"
