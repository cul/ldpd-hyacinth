# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::Params do
  let(:params) { described_class.new }

  context 'when creating fq queries' do
    it 'properly handles and escapes a single fq value' do
      params.fq('animals', 'dogs + cats')
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats)'])
    end

    it 'properly handles and escapes multiple values and defaults to match function' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'])
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats OR llamas OR alpacas)'])
    end

    it 'properly handles and escapes multiple values with the match param passed, OR-ing them together' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'], 'contains')
      expect(params.to_h).to include(fq: ['animals:(*dogs\ \+\ cats* OR *llamas* OR *alpacas*)'])
    end
  end

  context 'when creating q queries' do
    it 'solr escapes q values' do
      params.q('foo-bar')
      expect(params.to_h).to include(q: 'foo\-bar')
    end
  end

  context 'when creating sort' do
    it 'returns error if invalid direction' do
      expect {
        params.sort('title', 'invalid')
      }.to raise_error ArgumentError, 'direction must be one of asc, desc, instead got \'invalid\''
    end

    it 'adds sort param' do
      params.sort('title', 'desc')
      expect(params.to_h).to include(sort: 'title desc')
    end
  end
end
