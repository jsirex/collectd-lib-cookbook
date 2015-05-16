require 'spec_helper'

describe 'collectd-lib-test::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(step_into: ['collectd_conf_accumulator']).converge described_recipe
  end

  %w(plugin-syslog plugin-cpu memory proc-bash disk-sda disk-sdb csv-writter proc-sshd proc-standalone battery
     df entropy irq load interface proc-chef proc-carbon-cache swap users write_graphite exec custom-section).each do |conf|
    it "creates collectd conf for #{conf}" do
      expect(chef_run).to create_collectd_conf(conf)
    end
  end

  it 'creates configuration file' do
    expect(chef_run).to render_file('/etc/collectd/collectd.conf').with_content('Global Configuration')
  end
end
