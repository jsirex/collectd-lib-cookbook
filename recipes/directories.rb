directory node['collectd']['conf_dir'] do
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end

directory node['collectd']['base_dir'] do
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end

directory node['collectd']['plugin_dir'] do
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end

directory node['collectd']['extra_conf_dir'] do
  owner 'root'
  group 'root'
  mode '755'
  recursive true
end
