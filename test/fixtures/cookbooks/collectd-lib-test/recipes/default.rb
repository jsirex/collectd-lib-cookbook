# Building wrapper cookbook in same way as you will do that
include_recipe 'collectd-lib::packages'
include_recipe 'collectd-lib::directories'
include_recipe 'collectd-lib::config'
include_recipe 'collectd-lib::service'


# Actual declaration of configuration in separate recipe
include_recipe 'collectd-lib-test::plugins'

# Test custom section
collectd_conf 'custom-section' do
  conf %w(MySection with_key) => {
         'SameValues' => [1, 'two', [false, true]],
         'SubSection' => {
           'Key' => 'value'
         }
       }
end
