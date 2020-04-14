# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::Params do
  context 'when creating fq queries' do
    let(:params) { described_class.new }

    it 'properly handles and escapes a single fq value' do
      params.fq('animals', 'dogs + cats')
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats)'])
    end

    it 'properly handles and escapes multiple values and defaults to OR-ing them together' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'])
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats OR llamas OR alpacas)'])
    end

    it 'properly handles and escapes multiple values with the :and param passed, AND-ing them together' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'], :and)
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats AND llamas AND alpacas)'])
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
