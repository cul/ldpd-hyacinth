# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Language::AttributesLoader do
  let(:attributes_loader) { described_class.new(data_path) }
  let(:data_path) { nil }
  describe '.load' do
    context 'multiline field values' do
      let(:data) do
        "%%\
Type: region
Subtag: GB
Description: United Kingdom
Added: 2005-10-16
Comments: as of 2006-03-29 GB no longer includes the Channel Islands and
  Isle of Man; see GG, JE, IM"
      end
      let(:data_io) { StringIO.new(data) }
      let(:records) { described_class.load(data_io) }
      it do
        expect(records.length).to be 1
        comments = records.first['comments']
        expect(comments).to be_present
        expect(comments.first).to include('and Isle of Man; see')
      end
    end
    context 'multiple value fields' do
      let(:data) do
        "%%\
Type: variant
Subtag: unifon
Description: Unifon phonetic alphabet
Added: 2013-10-02
Prefix: en
Prefix: hup
Prefix: kyh
Prefix: tol
Prefix: yur"
      end
      let(:data_io) { StringIO.new(data) }
      let(:records) { described_class.load(data_io) }
      it do
        expect(records.length).to be 1
        prefixes = records.first['prefix']
        expect(prefixes).to be_present
        expect(prefixes).to eql(%w[en hup kyh tol yur])
      end
    end
    context 'multiple field sets' do
      let(:data) do
        "%%\
Type: variant
Subtag: ulster
Description: Ulster dialect of Scots
Added: 2010-04-10
Prefix: sco
%%
Type: variant
Subtag: newfound
Description: Newfoundland English
Added: 2015-11-25
Prefix: en-CA
%%"
      end
      let(:data_io) { StringIO.new(data) }
      let(:records) { described_class.load(data_io) }
      it do
        expect(records.length).to be 2
        prefixes = records.map { |record| record['prefix'] }.flatten.compact
        expect(prefixes).to be_present
        expect(prefixes).to eql(%w[sco en-CA])
      end
    end
  end
end
