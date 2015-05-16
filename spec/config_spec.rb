require 'spec_helper'

describe 'collectd-lib::config' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge('collectd-lib::service', described_recipe)
  end

  it 'creates collectd conf accumulator' do
    expect(chef_run).to create_collectd_conf_accumulator('collectd.conf')
  end

  it 'notifies service collectd to restart' do
    res = chef_run.collectd_conf_accumulator('collectd.conf')
    expect(res).to notify('service[collectd]').to(:restart).delayed
  end
end
