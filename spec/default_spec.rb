require 'spec_helper'

describe 'collectd-lib::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new.converge described_recipe
  end
end
