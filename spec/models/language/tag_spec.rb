# frozen_string_literal: true

require 'rails_helper'

describe Language::Tag do
  let(:iana_en_fixture) { file_fixture('files/iana_language/english-subtag-registry') }
  let(:iana_i_fixture) { file_fixture('files/iana_language/grandfathered-subtag-registry') }
  let(:iana_qu_fixture) { file_fixture('files/iana_language/quechua-subtag-registry') }
  let(:iana_zh_fixture) { file_fixture('files/iana_language/chinese-subtag-registry') }
  let(:use_preferred) { false }
  let(:lang_tag) { described_class.for(tag_value, use_preferred) }
  let(:preferred_value) { lang_tag.preferred_value }
  before do
    iana_fixtures.each do |iana_fixture|
      Hyacinth::Language::SubtagLoader.new(iana_fixture).load
    end
  end
  context 'tag has only a language' do
    let(:iana_fixtures) { [iana_en_fixture] }
    let(:tag_value) { 'en' }
    it "associates a suppressed script without including it in the tag" do
      expect(lang_tag.tag).to eql tag_value
      expect(lang_tag.suppressed_script&.subtag).to eql 'Latn'
    end
  end
  context 'tag has a region' do
    let(:iana_fixtures) { [iana_en_fixture] }
    let(:tag_value) { 'en-US' }
    it "associates a suppressed script without including it in the tag" do
      expect(lang_tag.tag).to eql tag_value
      expect(lang_tag.suppressed_script&.subtag).to eql 'Latn'
    end
    context 'tag has explicit but suppressed script' do
      let(:tag_value) { 'en-Latn-US' }
      it "associates a suppressed script without including it in the tag" do
        expect(lang_tag.tag).to eql tag_value
        expect(lang_tag.suppressed_script&.subtag).to eql 'Latn'
        expect(lang_tag.preferred_value&.tag).to eql 'en-US'
      end
    end
  end

  context 'tag has variants' do
    let(:iana_fixtures) { [iana_en_fixture] }
    context 'in correct context' do
      let(:tag_value) { 'en-CA-unifon-newfound' }
      it do
        expect(lang_tag.tag).to eql 'en-CA-unifon-newfound'
      end
      context 'out of preferred order' do
        let(:tag_value) { 'en-CA-newfound-unifon' }
        it "reorders by minimum match" do
          expect(lang_tag.tag).to eql 'en-CA-unifon-newfound'
        end
        context 'with same prefix' do
          let(:tag_value) { 'en-CA-newfound-unifon-cornu' }
          it "breaks ties with subtag value" do
            expect(lang_tag.tag).to eql 'en-CA-cornu-unifon-newfound'
          end
        end
      end
      context 'variants have no prefix restrictions' do
        let(:iana_fixtures) { [iana_qu_fixture] }
        let(:tag_value) { 'qu-Latn-alalc97' }
        it "permits association with any tag value" do
          expect(lang_tag.tag).to eql 'qu-Latn-alalc97'
        end
      end
    end
    context 'in incorrect context' do
      let(:primary_tag) { 'sco' }
      let(:good_variant) { 'ulster' }
      # unifon variant applies to English (en)
      let(:bad_variant) { 'unifon' }
      let(:tag_value) { "sco-unifon-ulster" }
      it 'raises' do
        expect { lang_tag }.to raise_error "variant unifon cannot be used in the context of sco"
      end
    end
  end
  context 'has extlangs' do
    let(:iana_fixtures) { [iana_zh_fixture] }
    context 'appropriate to language' do
      let(:tag_value) { 'zh-gan-Hant' }
      it do
        expect(lang_tag.tag).to eql tag_value
        expect(preferred_value.tag).to eql('gan-Hant')
      end
    end
    context 'without macrolanugage' do
      let(:tag_value) { 'gan-Hant' }
      it do
        expect(lang_tag.tag).to eql tag_value
        expect(preferred_value).to be_nil
      end
    end
    context 'inappropriate to language' do
      let(:bad_language) { 'en' }
      let(:extlang_subtag) { 'gan' }
      let(:tag_value) { "#{bad_language}-#{extlang_subtag}" }
      it 'raises' do
        expect { lang_tag }.to raise_error "Subtags extlang tag #{extlang_subtag} is not valid with language tag #{bad_language}"
      end
    end
  end
  context 'is grandfathered' do
    let(:iana_fixtures) { [iana_i_fixture] }
    context 'has preferred value' do
      let(:tag_value) { 'i-klingon' }
      let(:preferred_value) { 'tlh' }
      it do
        expect(lang_tag.tag).to eql tag_value
        expect(lang_tag.preferred_value&.tag).to eql(preferred_value)
      end
    end
    context 'has no preferred replacement' do
      let(:tag_value) { 'i-enochian' }
      it do
        expect(lang_tag.tag).to eql tag_value
      end
    end
  end
end
