module ChefCollectd
  module ConfigConverter
    class << self
      SPACER = ' ' * 8

      def collectd_key(k)
        case k
        when String
          k
        when Symbol
          k.to_s
        else
          fail TypeError, "Unexpected key `#{k.inspect}` of type `#{k.class}`."
        end
      end

      def collectd_value(v)
        case v
        when Fixnum, TrueClass, FalseClass
          v
        when String
          "\"#{v}\""
        when Array
          v.map { |x| collectd_value(x) }.join(' ')
        else
          fail TypeError, "Unexpected value `#{v.inspect}` of type `#{v.class}`."
        end
      end

      def indent_str(str, level = 0)
        str.split("\n").map { |s| "#{SPACER * level}#{s}" }.join("\n")
      end

      # Builds a collect section
      # @param [String, Symbol, Array] key
      # @param [String] content
      def collectd_section(key, content, level = 0)
        return '' if content.nil? || content.empty?

        output = []
        case key
        when String, Symbol
          output << indent_str("<#{collectd_key(key)}>", level)
          output << indent_str(content, level + 1)
          output << indent_str("</#{collectd_key(key)}>", level)
        when Array
          output << indent_str("<#{collectd_key(key[0])} #{collectd_value(key[1])}>", level)
          output << indent_str(content, level + 1)
          output << indent_str("</#{collectd_key(key[0])}>", level)
        end
        output.join("\n")
      end

      def from_hash(h, level = 0)
        fail TypeError, "`#{h.inspect}` is not Hash . This is `#{h.class}`" unless h.is_a? Hash

        output = []

        h.each_pair do |key, value|
          case value
          when Hash
            # We are in section
            content = from_hash(value)
            output << collectd_section(key, content, level)
          when Array
            # Multiple repeation
            value.each do |subvalue|
              output << indent_str("#{collectd_key(key)} #{collectd_value(subvalue)}")
            end
          else
            output << indent_str("#{collectd_key(key)} #{collectd_value(value)}")
          end
        end

        output.join("\n")
      end

      def from_resources(resources)
        output = []

        tuples = transform(resources)
        plugin_tuples = tuples.select { |t| t[:plugin] }
        conf_tuples = tuples - plugin_tuples

        conf_tuples = priority_sort(conf_tuples, :priority) # sort only by priority
        plugin_tuples = priority_sort(plugin_tuples, :plugin_name)

        plugin_names = find_plugin_names(plugin_tuples)

        plugin_names.each do |plugin_name|
          key = %W(Plugin #{plugin_name})
          plugins = plugin_tuples.select { |t| t[:plugin_name] == plugin_name }
          merged_plugins = plugins.select { |p| p[:merge] }
          standalone_plugins = plugins - merged_plugins

          # Plugin attribute may be hash. It is additional configuration for LoadPlugin Section
          load_plugin_conf = plugins.first[:plugin]
          case load_plugin_conf
          when String
            output << from_hash('LoadPlugin' => load_plugin_conf)
          when Hash
            output << from_hash(%W(LoadPlugin #{load_plugin_conf.keys.first}) => load_plugin_conf.values.first)
          else
            # Strange, but try to parse
            from_hash('LoadPlugin' => load_plugin_conf)
          end

          unless merged_plugins.empty?
            # Writting down all configuration one by one inside section
            content = merged_plugins.map { |mp| from_hash(mp[:conf]) }.join("\n")
            output << collectd_section(key, content)
          end

          standalone_plugins.each do |plugin|
            output << from_hash(key => plugin[:conf])
          end

          # Making empty string for readability
          output << ''
        end

        conf_tuples.each do |conf_tuple|
          output << from_hash(conf_tuple[:conf])
        end

        output.join("\n")
      end

      def find_plugin_names(tuples)
        tuples.map { |t| t[:plugin_name] }.uniq
      end

      def transform(res)
        res.map do |r|
          pn = case r.plugin
               when String
                 r.plugin
               when Hash
                 r.plugin.keys.first
               end

          {
            :priority => r.priority,
            :conf => r.conf,
            :plugin => r.plugin,
            :plugin_name =>  pn,
            :merge => r.merge
          }
        end
      end

      def priority_sort(tuples, key)
        tuples.sort { |x, y| x[:priority] == y[:priority] ? x[key] <=> y[key] : x[:priority] <=> y[:priority] }
      end
    end
  end
end
