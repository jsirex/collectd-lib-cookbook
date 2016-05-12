require 'spec_helper'
require_relative '../../libraries/chef_collectd_config_converter.rb'

describe ChefCollectd::ConfigConverter do
  describe '#collectd_key' do
    it 'returns string for string' do
      expect(described_class.collectd_key('string')).to eq('string')
    end

    it 'returns string for symbol' do
      expect(described_class.collectd_key(:string)).to eq('string')
    end

    it 'raises error for unsupported type of key' do
      expect { described_class.collectd_key({}) }.to raise_error(TypeError)
    end
  end

  describe '#collectd_value' do
    it 'returns quoted string for string' do
      expect(described_class.collectd_value('string')).to eq('"string"')
    end

    it 'returns few values for array' do
      array = [1, false, true, 'foo', ['bar', 2], '']
      expect(described_class.collectd_value(array)).to eq('1 false true "foo" "bar" 2 ""')
    end

    it 'raises error for unsupported type of value' do
      expect { described_class.collectd_value({}) }.to raise_error(TypeError)
    end
  end

  describe '#indent_str' do
    it 'keeps string untouched' do
      expect(described_class.indent_str('string')).to eq('string')
    end

    it 'indents string with 8 spaces for level 1' do
      expect(described_class.indent_str('string', 1)).to eq('        string')
    end

    it 'indents strings with 8 spaces for level 1' do
      str = "string1\nstring2\nstring3"
      result = "        string1\n        string2\n        string3"
      expect(described_class.indent_str(str, 1)).to eq(result)
    end
  end

  describe '#collectd_section' do
    it 'builds simple section' do
      key = 'MySection'
      content = 'test'
      result = "        <MySection>\n                test\n        </MySection>"
      expect(described_class.collectd_section(key, content, 1)).to eq(result)
    end

    it 'builds section with attribute' do
      key = %w(Sec value)
      content = 'test'
      result = "        <Sec \"value\">\n                test\n        </Sec>"
      expect(described_class.collectd_section(key, content, 1)).to eq(result)
    end

    it 'skips section if no content' do
      key = %w(Sec value)
      expect(described_class.collectd_section(key, '', 1)).to eq('')
      expect(described_class.collectd_section(key, nil, 1)).to eq('')
    end
  end

  describe '#from_hash' do
    it 'creates configuration from hash' do
      hash = {
        'Key' => 'value',
        'Arrays' => [1, 2, true, 'str', [5, 6, 7], %w(s s2), false, ''],
        'Sec' => { 'k' => 'v' },
        %w(Sec2 attr) => { 'kk' => %w(v v v) },
        %w(Multi section) => [
          { 'k1' => 'v1' },
          { 'k2' => 'v2' }
        ]
      }
      result = 'Key "value"
Arrays 1
Arrays 2
Arrays true
Arrays "str"
Arrays 5 6 7
Arrays "s" "s2"
Arrays false
Arrays ""
<Sec>
        k "v"
</Sec>
<Sec2 "attr">
        kk "v"
        kk "v"
        kk "v"
</Sec2>
<Multi "section">
        k1 "v1"
</Multi>
<Multi "section">
        k2 "v2"
</Multi>'
      expect(described_class.from_hash(hash)).to eq(result)
    end
  end
end
