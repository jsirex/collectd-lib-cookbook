require 'spec_helper'

describe 'collectd-lib::packages' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end

  it 'installs package collectd-core' do
    expect(chef_run).to install_package('collectd-core')
  end
end
