require 'serverspec'

set :backend, :exec

describe file('/etc/collectd/collectd.conf') do
  it { should be_file }

  its(:content) { should match('# This file is managed by Chef')}
  its(:content) { should match('# Global Configuration         #')}
  its(:content) { should match('# Plugins Configuration        #')}
  its(:content) { should match('PluginDir "/usr/lib/collectd"') }
  its(:content) { should match('BaseDir "/var/lib/collectd"')}
  its(:content) { should match('PluginDir "/usr/lib/collectd"')}
  its(:content) { should match('TypesDB "/usr/share/collectd/types.db"')}
  its(:content) { should match('Interval 10')}
  its(:content) { should match('WriteQueueLimitHigh 1000000')}
  its(:content) { should match('WriteQueueLimitLow 900000')}
  its(:content) { should match('LoadPlugin "syslog"')}
  its(:content) { should match('LoadPlugin "cpu"')}
  its(:content) { should match('LoadPlugin "exec"')}
  its(:content) { should match('<Plugin "syslog">')}
  its(:content) { should match('<Plugin "exec">')}
end
