<?php
$CONFIG = array (
  // 0 = Debug, 1 = Info, 2 = Warning, 3 = Error, 4 = Fatal
  'loglevel' => 2,
  'log_rotate_size' => 104857600,
  'filesystem_check_changes' => 1,
  // 'version.hide' is ownCloud only...
  'version.hide' => true,
  // 'excluded_directories' is ownCloud only...
  'excluded_directories' =>
        array (
                '.snapshot',
                '~snapshot',
                '.well-known',
                '.zfs',
        ),
  // 'integrity.excluded.files' is ownCloud only...
  'integrity.excluded.files' =>
        array (
                '.DS_Store',
                'Thumbs.db',
                '.directory',
                '.webapp',
                '.htaccess',
                '.user.ini',
                '.well-known/acme-challenge/.htaccess',
                'apc.php',
        ),
  'simpleSignUpLink.shown' => false,
);
