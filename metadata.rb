# Completely rewritten from scratch
name             'collectd-lib'
maintainer       'Yauhen Artsiukhou'
maintainer_email 'jsirex@gmail.com'
license          'Apache 2.0'
description      'Install and configure the collectd monitoring daemon'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url       'https://github.com/jsirex/collectd-lib-cookbook/issues'
source_url       'https://github.com/jsirex/collectd-lib-cookbook'
version          '3.0.2'

supports 'debian'
supports 'ubuntu'

conflicts 'collectd'
