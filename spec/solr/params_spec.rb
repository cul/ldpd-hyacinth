# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::Params do
  let(:params) { described_class.new }

  context 'when creating fq queries' do
    it 'properly handles and escapes a single fq value' do
      params.fq('animals', 'dogs + cats')
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats)'])
    end

    it 'properly handles and escapes multiple values with default equals comparison, OR-ing them together' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'])
      expect(params.to_h).to include(fq: ['animals:(dogs\ \+\ cats OR llamas OR alpacas)'])
    end

    it 'properly handles and escapes multiple values with the match param passed, OR-ing them together' do
      params.fq('animals', ['dogs + cats', 'llamas', 'alpacas'], 'CONTAINS')
      expect(params.to_h).to include(fq: ['animals:(*dogs\ \+\ cats* OR *llamas* OR *alpacas*)'])
    end

    it 'allows the same fq key to be added twice, thereby AND-ing across the separate fqs' do
      params.fq('animals', ['cool cats', 'hot dogs'], 'CONTAINS')
      params.fq('animals', ['cool llamas', 'hot alpacas'], 'CONTAINS')
      expect(params.to_h).to include(fq: ['animals:(*cool\ cats* OR *hot\ dogs*)', 'animals:(*cool\ llamas* OR *hot\ alpacas*)'])
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

  context 'when making a facet values query' do
    let(:facet_name) { 'animals' }
    let(:rows) { (0..100).to_a.sample(1) }
    let(:start) { (0..100).to_a.sample(1) }
    let(:sort) { 'count' }
    # sort_direction not used until Solr 8
    let(:sort_direction) { 'asc' }
    let(:expected) do
      {
        :"f.#{facet_name}.facet.limit" => rows,
        :"f.#{facet_name}.facet.offset" => start,
        :"f.#{facet_name}.facet.sort" => sort,
        :"stats.field" => "{!countDistinct=true}#{facet_name}",
        stats: 'on'
      }
    end
    before do
      params.facet_on(facet_name) do |f_params|
        f_params.start(start)
        f_params.rows(rows)
        f_params.sort(sort, sort_direction)
        f_params.with_statistics!
      end
    end

    it 'adds facet value params' do
      actual = params.to_h
      expect(actual).to include(expected)
    end
  end
end
