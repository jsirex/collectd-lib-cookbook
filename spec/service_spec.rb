require 'spec_helper'

describe 'collectd-lib::service' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end

  it 'enables service collectd' do
    expect(chef_run).to enable_service('collectd')
  end
end
