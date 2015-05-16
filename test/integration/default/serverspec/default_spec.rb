require 'serverspec'

set :backend, :exec

describe package('collectd-core') do
  it { should be_installed }
end

describe process('collectd') do
  it { should be_running }
end

describe command('collectd -t') do
  # there is bug in exit code for collectd 5.1.0 (always return 0)
  its(:stdout) { should eq '' }
  # in version >= 5.4.0 use exit code
  its(:exit_status) { should eq 0 }
end
