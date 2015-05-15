file 'collectd.conf' do
  path ::File.join(node['collectd']['conf_dir'], 'collectd.conf')
  owner 'root'
  group 'root'
  mode '644'

  action :nothing
end

collectd_conf_accumulator 'collectd.conf' do
  collect :collectd_conf
  options 'FQDNLookup' => node['collectd']['fqdn_lookup'],
          'BaseDir' => node['collectd']['base_dir'],
          'PluginDir' => node['collectd']['plugin_dir'],
          'TypesDB' => node['collectd']['types_db'],
          'Interval' => node['collectd']['interval'],
          'Timeout' => node['collectd']['timeout'],
          'ReadThreads' => node['collectd']['read_threads'],
          'WriteThreads' => node['collectd']['write_threads'],
          'WriteQueueLimitHigh' => node['collectd']['write_queue_limit_high'],
          'WriteQueueLimitLow' => node['collectd']['write_queue_limit_low']

  extra_conf_dir node['collectd']['extra_conf_dir']

  notifies :restart, 'service[collectd]'
end
