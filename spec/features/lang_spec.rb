# frozen_string_literal: true

require 'rails_helper'

describe 'default language', type: :feature do
  # this runs in an initializer, but rspec tears db down between tests
  before { Hyacinth::Language.load_default_subtags! }
  it do
    expect(Hyacinth::Config.default_lang_value).to be_a ::Language::Tag
  end
end
