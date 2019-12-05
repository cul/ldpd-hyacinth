# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::Params do
  context 'when creating fq queries' do
    let(:params) { described_class.new }

    it 'solr escapes fq values' do
      params.fq('animals', 'dogs+cats')
      expect(params.to_h).to include(fq: ['animals:"dogs\+cats"'])
    end
  end

  context 'when creating q queries' do
    let(:params) { described_class.new }

    it 'solr escapes q values' do
      params.q('foo-bar')
      expect(params.to_h).to include(q: 'foo\-bar')
    end
  end
end
