# frozen_string_literal: true

require 'rails_helper'

class StringKeyValidatable
  include ActiveModel::Validations
  attr_accessor :string_key

  validates :string_key, string_key: true
end

RSpec.describe StringKeyValidator do
  subject(:obj) { StringKeyValidatable.new }

  context 'with invalid string key' do
    ['1potter', 'harry__potter', 'harry_potter_', '_harry_potter'].each do |invalid_str|
      it "returns invalid for string: #{invalid_str}" do
        obj.string_key = invalid_str
        expect(obj.valid?).to be false
        expect(
          obj.errors[:string_key]
        ).to match_array('values must be up to 240 characters long, start with a lowercase letter, groupings of lowercase letters and numbers can be seperated by ONE underscore')
      end
    end
  end

  context 'with valid string key' do
    it "returns valid" do
      obj.string_key = 'harry_potter'
      expect(obj.valid?).to be true
    end
  end
end
