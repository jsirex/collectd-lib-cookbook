if defined?(ChefSpec)
  ChefSpec::Runner.define_runner_method(:collectd_conf)

  def add_collectd_plugin(plugin)
    ChefSpec::Matchers::ResourceMatcher.new(:collectd_conf, :create, plugin)
  end
end
