# frozen_string_literal: true

shared_context 'with language subtag fixtures' do
  let(:iana_en_fixture) { file_fixture('files/iana_language/english-subtag-registry') }
  let(:iana_i_fixture) { file_fixture('files/iana_language/grandfathered-subtag-registry') }
  let(:iana_qu_fixture) { file_fixture('files/iana_language/quechua-subtag-registry') }
  let(:iana_zh_fixture) { file_fixture('files/iana_language/chinese-subtag-registry') }
end

shared_context 'with english-adjacent language subtags' do
  include_context 'with language subtag fixtures'
  before do
    Hyacinth::Language::SubtagLoader.new(iana_en_fixture).load
  end
end

shared_context 'with chinese-adjacent language subtags' do
  include_context 'with language subtag fixtures'
  before do
    Hyacinth::Language::SubtagLoader.new(iana_zh_fixture).load
  end
end

shared_context 'with quechua-adjacent language subtags' do
  include_context 'with language subtag fixtures'
  before do
    Hyacinth::Language::SubtagLoader.new(iana_qu_fixture).load
  end
end

shared_context 'with grandfathered language subtags' do
  include_context 'with language subtag fixtures'
  before do
    Hyacinth::Language::SubtagLoader.new(iana_i_fixture).load
  end
end

shared_context 'with system default language subtags' do
  before do
    Hyacinth::Language.load_default_subtags!
  end
end
