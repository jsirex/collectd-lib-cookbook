collectd_conf 'plugin-syslog' do
  plugin 'syslog'
  conf 'LogLevel' => 'info'
  priority 0
end

collectd_conf 'plugin-cpu' do
  plugin 'cpu'
end

collectd_conf 'memory' do
  plugin 'memory'
end

collectd_conf 'proc-bash' do
  plugin 'processes'
  conf 'Process' => 'bash'
end

collectd_conf 'disk-sda' do
  plugin 'disk'
  conf 'Disk' => 'sda', 'IgnoreSelected' => 'false'
end

collectd_conf 'disk-sdb' do
  plugin 'disk'
  conf 'Disk' => 'sdb'
end

collectd_conf 'csv-writter' do
  plugin 'csv'
  conf 'DataDir' => '/tmp', 'StoreRates' => false
end

collectd_conf 'proc-sshd' do
  plugin 'processes'
  conf 'Process' => 'sshd'
end

collectd_conf 'proc-standalone' do
  plugin 'processes'
  conf 'Process' => 'standaloneproc'
  merge false
end

collectd_conf 'battery' do
  plugin 'battery'
end

collectd_conf 'df' do
  plugin 'df'
  conf 'MountPoint' => '/',
       'ValuesPercentage' => true
end

collectd_conf 'entropy' do
  plugin 'entropy'
end

collectd_conf 'irq' do
  plugin 'irq'
end

collectd_conf 'load' do
  plugin 'load'
end

collectd_conf 'interface' do
  plugin 'interface'
  conf 'Interface' => 'eth0'
end

collectd_conf 'proc-chef' do
  plugin 'processes'
  conf 'ProcessMatch' => [ %w(chef-client /opt/chef/embedded/bin/ruby /usr/bin/chef-client) ]
end

collectd_conf 'proc-carbon-cache' do
  plugin 'processes'
  conf 'ProcessMatch' => [['carbon-cache', 'python.+carbon-cache']]

end

collectd_conf 'swap' do
  plugin 'swap'
end

collectd_conf 'users' do
  plugin 'users'
end

collectd_conf 'write_graphite' do
  plugin 'write_graphite'
  conf %w(Node example) => {
         'Host' => 'localhost',
         'Port' => '2003',
         'Protocol' => 'udp',
         'LogSendErrors' => true,
         'Prefix' => 'collectd'
       }
end

collectd_conf 'exec' do
  plugin 'exec'
  conf 'Exec' => [ %w(root:root program opt1 opt2 opt3) ]
end

=begin
This is only for example of usage.
Most of collectd plugins requires additional libraries have installed in the system

collectd_conf 'python' do
  plugin 'python' => {'Globals' => true}
  conf 'ModulePath' => '/path/to/your/modules',
       'Import' => 'spam',
       'Interactive' => false,
       'LogTraces' => true,
       %w(Module spam) => {
         'spam' => %w(wonderful lovely)
       }
end

collectd_conf 'python-two' do
  plugin 'python' => {'Globals' => true}
  conf 'ModulePath' => '/path/to/your/modules',
       'Import' => 'pypy',
       'Interactive' => false,
       'LogTraces' => true,
       %w(Module pypy) => {
         'pypy' => [ %w(py py py) ]
       }
end
=end
