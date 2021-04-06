<?php
$AUTOCONFIG = array(
  "directory"     => "/srv/owncloud/data",

//  "dbtype"        => "sqlite",
//  "dbname"        => "owncloud",
//  "dbtableprefix" => "",

//  'dbtype' => 'mysql',
//  'dbhost' => 'mysql';
//  'dbname' => 'owncloud';
//  'dbuser' => 'my_user';
//  'dbpass' => 'my_password';
//  'dbtableprefix' => 'oc_';
//  'dbdriveroptions' => array(
//        PDO::MYSQL_ATTR_SSL_CA => '/file/path/to/ca_cert.pem',
//        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET wait_timeout = 28800'
//  ),

  'default_language' => 'en',
  'log_rotate_size' => 104857600,
  'filesystem_check_changes' => 1,
  'asset-pipeline.enabled' => true,

  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://owncloud.example.org/',

  'activity_expire_days' => 61,

  'trashbin_retention_obligation' => 'auto,61',
  'versions_retention_obligation' => 'auto,366',

	'apps_paths' => array(
		array(
			'path'=> OC::$SERVERROOT.'/apps',
			'url' => '/apps',
			'writable' => false,
		),
		array(
			'path'=> OC::$SERVERROOT.'/apps-external',
			'url' => '/apps-external',
			'writable' => true,
		),
	),

  'memcache.local' => '\OC\Memcache\APCu',
  // Distributed cache for multi-server ownCloud installations
  // If unset, defaults to the value of memcache.local
//  'memcache.distributed' => '\OC\Memcache\Memcached',
//  'memcached_servers' =>
//  array (
//    0 =>
//    array (
//      0 => 'memcached',
//      1 => 11211,
//    ),
//  ),
  'memcached_options' => array(
        // Set timeouts to 50ms
        //\Memcached::OPT_CONNECT_TIMEOUT => 50,
        //\Memcached::OPT_RETRY_TIMEOUT =>   50,
        //\Memcached::OPT_SEND_TIMEOUT =>    50,
        //\Memcached::OPT_RECV_TIMEOUT =>    50,
        //\Memcached::OPT_POLL_TIMEOUT =>    50,

        // Enable compression
        \Memcached::OPT_COMPRESSION =>          true,

        // Turn on consistent hashing
        \Memcached::OPT_LIBKETAMA_COMPATIBLE => true,

        // Enable Binary Protocol
        \Memcached::OPT_BINARY_PROTOCOL =>      true,

        // Binary serializer vill be enabled if the igbinary PECL module is available
        //\Memcached::OPT_SERIALIZER => \Memcached::SERIALIZER_IGBINARY,
  ),
  'memcache.locking' => '\OC\Memcache\Redis', // Because most memcache backends can clean values without warning using redis is highly recommended to avoid data loss.
  'filelocking.enabled' => 'true',
  'redis' => array(
    'host' => 'redis-owncloud', // can also be a unix domain socket: '/var/run/redis/redis.sock'
    'port' => 6379,
//    'timeout' => 0.0,
//    'password' => '', // Optional, if not defined no password will be used.
//    'dbindex' => 0, // Optional, if undefined SELECT will not run and will use Redis Server's default DB Index.
  ),

  'mail_domain' => 'example.org',
  'mail_from_address' => 'owncloud-no-reply',
  //'mail_smtpdebug' => true,
  'mail_smtpmode' => 'smtp',
//  'mail_smtphost' => '127.0.0.1;email-relay',
  'mail_smtphost' => 'email-relay',
  'mail_smtpport' => 25,
  'mail_smtptimeout' => 10,
  'mail_smtpsecure' => '',

  'enable_previews' => false,
  'preview_max_x' => 512,
  'preview_max_y' => 512,
  'preview_max_scale_factor' => 1,
);
