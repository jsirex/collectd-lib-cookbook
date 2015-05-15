node['collectd']['packages'].each do |pkg|
  package pkg
end
