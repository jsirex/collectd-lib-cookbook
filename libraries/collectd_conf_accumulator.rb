require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource
    class CollectdConfAccumulator < Chef::Resource
      identity_attr :name

      def initialize(*_args)
        super

        @resource_name = :collectd_conf_accumulator
        @provider = Chef::Provider::CollectdConfAccumulator

        @collect = nil
        @options = {}
        @extra_conf_dir = nil

        @action = :create
      end

      def collect(arg = nil)
        set_or_return(:collect, arg, :kind_of => [Symbol])
      end

      def options(arg = nil)
        set_or_return(:options, arg, :kind_of => [Hash])
      end

      def extra_conf_dir(arg = nil)
        set_or_return(:extra_conf_dir, arg, :kind_of => [String])
      end
    end
  end

  class Provider
    class CollectdConfAccumulator < Chef::Provider
      def whyrun_supported?
        false
      end

      def load_current_resource
        @current_resource = new_resource
      end

      def action_create
        file_resource = run_context.resource_collection.find(:file => new_resource.name)
        conf_resources = run_context.resource_collection.select do |x|
          x.resource_name == new_resource.collect && Array(x.action).include?(:create)
        end

        content = "# This file is managed by Chef, your changes *will* be overwritten!\n\n"
        content << "################################\n"
        content << "# Global Configuration         #\n"
        content << "################################\n\n"
        content << ChefCollectd::ConfigConverter.from_hash(new_resource.options)
        content << "\n\n"

        content << "################################\n"
        content << "# Plugins Configuration        #\n"
        content << "################################\n\n"
        content << ChefCollectd::ConfigConverter.from_resources(conf_resources)
        content << "\n\n"

        content << "################################\n"
        content << "# Extra Configuration Include  #\n"
        content << "################################\n\n"
        content << ChefCollectd::ConfigConverter.from_hash(%W(Include #{new_resource.extra_conf_dir}) => { 'Filter' => '*.conf'})
        content << "\n"

        file_resource.content content

        file_resource.run_action(:create)

        if file_resource.updated_by_last_action?
          new_resource.updated_by_last_action(true)
        end
      end
    end
  end

end
