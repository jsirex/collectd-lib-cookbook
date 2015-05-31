require 'spec_helper'

describe 'collectd-lib::directories' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end

  %w(/etc/collectd /var/lib/collectd /usr/lib/collectd /etc/collectd/collectd.conf.d).each do |d|
    it "create directory #{d}" do
      expect(chef_run).to create_directory(d)
    end
  end
end
