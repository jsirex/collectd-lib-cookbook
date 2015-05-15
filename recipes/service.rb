service 'collectd' do
  supports :status => true, :restart => true
  action :enable
end
