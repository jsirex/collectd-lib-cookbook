require 'chef/resource'
require 'chef/provider'

class Chef
  class Resource
    class CollectdConf < Chef::Resource
      identity_attr :name

      def initialize(name, run_context = nil)
        super

        @resource_name = :collectd_conf

        @plugin = nil
        @priority = 10
        @merge = true
        @conf = {}

        @action = :create
        @provider = Chef::Provider::CollectdConf
      end

      def conf(arg = nil)
        validate_conf!(arg) if arg

        set_or_return(:conf, arg, :kind_of => [Hash])
      end

      def plugin(arg = nil)
        set_or_return(:plugin, arg, :kind_of => [String, Hash])
      end

      def priority(arg = nil)
        set_or_return(:priority, arg, :kind_of => [Fixnum])
      end

      def merge(arg = nil)
        set_or_return(:merge, arg, :kind_of => [TrueClass, FalseClass])
      end

      def validate_conf!(conf)
        ChefCollectd::ConfigConverter.from_hash(conf)
      rescue TypeError => e
        raise ArgumentError, "#{self} (#{defined_at}) wrong configuration: #{conf}. #{e}"
      end
    end
  end

  class Provider
    class CollectdConf < Chef::Provider
      def load_current_resource
        true
      end

      def whyrun_supported?
        false
      end

      def action_create
      end
    end
  end
end
