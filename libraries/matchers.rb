if defined?(ChefSpec)
  ChefSpec.define_matcher(:collectd_conf)
  ChefSpec.define_matcher(:collectd_conf_accumulator)

  def create_collectd_conf(plugin)
    ChefSpec::Matchers::ResourceMatcher.new(:collectd_conf, :create, plugin)
  end

  def create_collectd_conf_accumulator(name)
    ChefSpec::Matchers::ResourceMatcher.new(:collectd_conf_accumulator, :create, name)
  end
end
