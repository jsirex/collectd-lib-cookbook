# Packages
default['collectd']['packages'] = %w(collectd-core)

# Directories
default['collectd']['conf_dir'] = '/etc/collectd'
default['collectd']['base_dir'] = '/var/lib/collectd'
default['collectd']['plugin_dir'] = '/usr/lib/collectd'
default['collectd']['extra_conf_dir'] = '/etc/collectd/colectd.conf.d'

# Base Configuration
default['collectd']['types_db'] = ['/usr/share/collectd/types.db']
default['collectd']['interval'] = 10
default['collectd']['timeout'] = 2
default['collectd']['read_threads'] = 5
default['collectd']['write_threads'] = 5
default['collectd']['write_queue_limit_high'] = 1000000
default['collectd']['write_queue_limit_low'] = 900000
default['collectd']['fqdn_lookup'] = false
