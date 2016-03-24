<?php
$AUTOCONFIG = array(
  "directory"     => "/srv/owncloud/data",

  "dbtype"        => "sqlite",
  "dbname"        => "owncloud",
  "dbtableprefix" => "",
//  'dbtype' => 'mysql',
//  'dbhost' => 'mysql';
//  'dbname' => 'owncloud';
//  'dbuser' => 'my_user';
//  'dbpass' => 'my_password';
//  'dbtableprefix' => 'oc_';

  'default_language' => 'en',
  'log_rotate_size' => 104857600,
  'filesystem_check_changes' => 1,
  'asset-pipeline.enabled' => true,

  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://owncloud.example.org/',

  'trashbin_retention_obligation' => 'auto,61',
  'versions_retention_obligation' => 'auto,366',

	'apps_paths' => array(
		array(
			'path'=> OC::$SERVERROOT.'/apps',
			'url' => '/apps',
			'writable' => false,
		),
		array(
			'path'=> OC::$SERVERROOT.'/apps2',
			'url' => '/apps2',
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
  'memcache.locking' => '\OC\Memcache\Redis', // Because most memcache backends can clean values without warning using redis is highly recommended to avoid data loss.
  'filelocking.enabled' => 'true',
  'redis' => array(
    'host' => 'redis', // can also be a unix domain socket: '/var/run/redis/redis.sock'
    'port' => 6379,
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
