# Description

Library cookbook for the [collectd](http://collectd.org/) monitoring daemon.
This cookbook introduce *accumulator* pattern for managing plugins.
I have to rename it from `collectd` to `collectd-lib` because I want to publish it to supermarket. And it conflicts with existing one.

## Usage

**By default cookbook does nothing**. You have to wrap it in your projects' cookbook. See example in `test/fixtures` folder.

## HWRP

### collectd\_conf

The `collectd_conf` defines configuration for collectd. The config is represented as a Hash and its syntax may be complecated.
This resource is very smart.

#### Usage

Cookbook generates `node['collectd']['conf_dir']/collectd.conf` file. It consists of four main parts:

1. Base Configuration. Manage it via node attributes
1. Dynamic Section for all plugins (tuples, sorted by priority and name)
1. Dynamic Section for all generic configurations (tuples, sorted by priority)
1. `Include` directive for extra config files. By default from `/etc/collectd/collectd.conf.d/*.conf`

Dynamic sections consists of tuples. Each `collectd_conf` defines a tuple. It uses **conf** attributes as a **Hash** for config source.

The **conf** hash is converted to collectd-style settings automatically. Here is the rules for **conf**:

If **key** is a *String* and **value** is a *String* it produces `Key "value"`:

```ruby
collectd_conf 'string-string' do
  conf 'Key' => 'Value', 'Key2' => 'Value2'
end
```

Result:

```
Key "value"
Key2 "value2"
```

If **key** is a *String* and **value** is a *Fixnum* it produces `Key value`:

```ruby
collectd_conf 'string-fixnum' do
  conf 'TheAnswerIs' => 42
end
```

Result:

```
TheAnswerIs 42
```

If **key** is a *String* and **value** is a *Array* it produces lines `Key value` for each value.

```ruby
collectd_conf 'string-array' do
  conf 'MultipleLines' => [1, "string", ["ar", "ray"]],
       'MultipleValues' => [ [1, 2, false] ]
end
```

Result:

```
MultipleLines 1
MultipleLines "string"
MultipleLines "ar" "ray"
MultipleValues 1 2 false
```

If **key** is a *String* and **value** is a *Hash* it produces section.

```ruby
collectd_conf 'string-hash' do
  conf 'Section' => {
    'Key' => 'value',
    'SubSection' => {
      'SubKey' => 'SubValue'
    }
  }
end
```

Result:

```
<Section>
  Key "value"
  <SubSection>
    SubKey "SubValue"
  </SubSection>
</Section>
```

If **key** is a *String* and **value** is an *Array* of *Hash* it produces multiple sections with the same name.
```ruby
collectd_conf 'string-hash-array' do
  conf 'Section' => [
    {'Key1' => 'Value1'},
    {'Key2' => 'Value2'}
  ]
end
```

Result:

```
<Section>
  Key1 "Value1"
</Section>
<Section>
  Key2 "Value2"
</Section>
```

If **key** is a *Array* and **value** is a *Hash* it produces section with `key[0]` name and attribute `key[1]`.

```ruby
collectd_conf 'array-hash' do
  conf %w(Include /etc/collectd/collectd.conf.d) => {
    'Filter' => '*.conf'
  }
end
```

Result:

```
<Include "/etc/collectd/collectd.conf.d">
  Filter "*.conf"
</Include>
```

One more:

```ruby
collectd_conf 'curl' do
  plugin 'curl'
  conf %w(Page stock_quotes) => {
    'URL' => 'http://finance.google.com/finance?q=NYSE%3AAMD',
    'User' => 'foo',
    'Password' => 'bar',
    'Match' => { 'Regexp' => 'blabla.*', 'DsType' => 'GaugeAverage' }
  }
end
```

Produces:

```
LoadPlugin "curl"
<Plugin "curl">
  <Page "stock_quotes">
    URL "http://finance.google.com/finance?q=NYSE%3AAMD"
    User "foo"
    Password "bar"
    <Match>
        Regexp "blabla.*"
        DsType "GaugeAverage"
    </Match>
  </Page>
</Plugin>
```


Here is the rules for **plugin** attribute:

If it is value is a *String* and **conf** is `nil` it produces `LoadPlugin "value"`

```ruby
collectd_conf 'plugin-string' do
  plugin 'cpu'
end
```

Result:

```
LoadPlugin "cpu"
```

If it is value is a *String* and **conf** not `nil` it produces `LoadPlugin "value"` and plugin section. **conf** goes into plugin section

```ruby
collectd_conf 'plugin-string-conf' do
  plugin 'disk'
  conf 'Disk' => %w(sda sdb sdc sdd)
end
```

Result:

```
LoadPlugin "disk"
<Plugin "disk">
  Disk "sda"
  Disk "sdb"
  Disk "sdc"
  Disk "sdd"
</Plugin>
```

If it is value is a *Hash* it produces `LoadPlugin` section

```ruby
collectd_conf 'plugin-hash-conf' do
  plugin 'python' => {'Globals' => true}
  conf 'Module' => 'SomeModule',
       'DeepConf' => {...}
end
```

Result:

```
<LoadPlugin "python">
  Globals true
</LoadPlugin>
<Plugin "python">
  Module "SomeModule"
  <DeepConf>
  ...
  </DeepConf>
</Plugin>
```

Repeation `collectd_conf` in different cookbooks and places for same plugin automatically merges all configuration together.
Use `merge false` to create standalone entry.

For logging plugins it is make sense to set `priority` above `10` so it appears earler in configuration.

**Merge works only for plugins.**

#### Actions

- **create** - default, adds configuration to collectd
- **nothing** - does nothing

#### Attributes

- **plugin** - plugin name to load. Can be **String** for name or **Hash** for `LoadPlugin` section. Defaults to `nil`
- **conf** - configuration. If plugin set - confgiration for plugin else generic configuration. Defaults to `nil`
- **merge** - merge or not configurations. **Works only for plugins**. Defaults to `true`
- **priority** - weather plugin or section appears early or later in config. Generic sections are always after plugins. Defaults to `10`

# NOTICE

This cookbook heavy refactored but still not well tested. Also it supports only `Debian`. But you can implement your own installation and use this cookbook only for configuration.

# Requirements

## Platform:

* debian
* ubuntu

## Cookbooks:

* Conflicts with collectd

# Attributes

* `node['collectd']['packages']` -  Defaults to `%w(collectd-core)`.
* `node['collectd']['conf_dir']` -  Defaults to `/etc/collectd`.
* `node['collectd']['base_dir']` -  Defaults to `/var/lib/collectd`.
* `node['collectd']['plugin_dir']` -  Defaults to `/usr/lib/collectd`.
* `node['collectd']['extra_conf_dir']` -  Defaults to `/etc/collectd/collectd.conf.d`.
* `node['collectd']['types_db']` -  Defaults to `[ ... ]`.
* `node['collectd']['interval']` -  Defaults to `10`.
* `node['collectd']['timeout']` -  Defaults to `2`.
* `node['collectd']['read_threads']` -  Defaults to `5`.
* `node['collectd']['write_threads']` -  Defaults to `5`.
* `node['collectd']['write_queue_limit_high']` -  Defaults to `1000000`.
* `node['collectd']['write_queue_limit_low']` -  Defaults to `900000`.
* `node['collectd']['fqdn_lookup']` -  Defaults to `false`.

# Recipes

* collectd-lib::config
* collectd-lib::default
* collectd-lib::directories
* collectd-lib::packages
* collectd-lib::service

# License and Maintainer

Maintainer:: Yauhen Artsiukhou (<jsirex@gmail.com>)
Source:: https://github.com/jsirex/collectd-lib-cookbook
Issues:: https://github.com/jsirex/collectd-lib-cookbook/issues

License:: Apache 2.0
