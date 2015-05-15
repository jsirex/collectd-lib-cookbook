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
          raise TypeError, "Unexpected key `#{k.inspect}` of type `#{k.class}`."
        end
      end

      def collectd_value(v)
        case v
        when Fixnum, TrueClass, FalseClass
          v
        when String
          "\"#{v}\""
        when Array
          v.map{ |x| collectd_value(x) }.join(' ')
        else
          raise TypeError, "Unexpected value `#{v.inspect}` of type `#{v.class}`."
        end
      end

      # Builds a collect section
      def collectd_section(key, content, level = 0)
        indent = SPACER * level
        output = []
        case key
        when String, Symbol
          output << "#{indent}<#{collectd_key(key)}>"
          output << content
          output << "#{indent}</#{collectd_key(key)}>"
        when Array
          output << "#{indent}<#{collectd_key(key[0])} #{collectd_value(key[1])}>"
          output << content
          output << "#{indent}</#{collectd_key(key[0])}>"
        end

        output.join("\n")
      end

      def from_hash(h, level = 0)
        raise TypeError, "`#{h.inspect}` is not Hash . This is `#{h.class}`" unless h.is_a? Hash

        indent = SPACER * level
        output = []

        h.each_pair do |key, value|
          case value
          when Hash
            # We are in section
            content = from_hash(value, level + 1)
            output << collectd_section(key, content, level)
          when Array
            # Multiple repeation
            value.each do |subvalue|
              output << "#{indent}#{collectd_key(key)} #{collectd_value(subvalue)}"
            end
          else
            output << "#{indent}#{collectd_key(key)} #{collectd_value(value)}"
          end
        end

        output.join("\n")
      end

      def from_resources(resources)
        output = []

        tuples = transform(resources)
        plugin_tuples = tuples.select {|t| t[:plugin]}
        conf_tuples = tuples - plugin_tuples

        conf_tuples = priority_sort(conf_tuples, :priority) # sort only by priority
        plugin_tuples = priority_sort(plugin_tuples, :plugin_name)

        plugin_names = find_plugin_names(plugin_tuples)

        plugin_names.each do |plugin_name|
          key = %W(Plugin #{plugin_name})
          plugins = plugin_tuples.select {|t| t[:plugin_name] == plugin_name}
          merged_plugins = plugins.select {|p| p[:merge]}
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
            content = merged_plugins.map {|mp| from_hash(mp[:conf], 1)}.join("\n")
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
        tuples.map {|t| t[:plugin_name]}.uniq
      end

      def transform(res)
        res.map do |r|
          pn = case r.plugin
               when String
                 r.plugin
               when Hash
                 r.plugin.keys.first
               else
                 nil
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
        tuples.sort { |x,y| x[:priority] == y[:priority] ? x[key] <=> y[key] : x[:priority] <=> y[:priority] }
      end

    end
  end
end
