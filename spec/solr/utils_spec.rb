# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::Utils do
  describe '.suffix' do
    {
      'string' => '_si',
      'integer' => '_ii',
      'boolean' => '_bi'
    }.each do |value, expected_suffix|
      it "returns the correct suffix for type: #{value}" do
        expect(described_class.suffix(value)).to eq(expected_suffix)
      end
    end
  end

  describe '.escape' do
    {
      '+ - & | ! ( ) { } [ ] ^ " ~ * ? : \ /' => '\\+ \\- \\& \\| \\! \\( \\) \\{ \\} \\[ \\] \\^ \\" \\~ \\* \\? \\: \\\\ \\/',
      'there is nothing to escape here' => 'there is nothing to escape here',
      'a^2 + b^2 = c^2' => 'a\\^2 \\+ b\\^2 = c\\^2',
      '(1+1)*(2+2)' => '\\(1\\+1\\)\\*\\(2\\+2\\)'
    }.each do |unescaped, escaped|
      it "escapes #{unescaped} to #{escaped}" do
        expect(described_class.escape(unescaped)).to eq(escaped)
      end
    end

    it 'returns unmodified boolean values if they are passed to the val parameter' do
      expect(described_class.escape(true)).to eq(true)
      expect(described_class.escape(false)).to eq(false)
    end

    it 'does not escape spaces by default' do
      expect(described_class.escape('a b c')).to eq('a b c')
    end

    it 'properly escapes spaces when the escape_spaces param is given a value of true' do
      expect(described_class.escape('a + b + c', true)).to eq('a\\ \\+\\ b\\ \\+\\ c')
    end
  end
end
