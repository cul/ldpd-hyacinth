# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Title do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass, :with_ascii_title) }
  let(:new_title) do
    {
      'value' => {
        'sort_portion' => 'The',
        'non_sort_portion' => 'New Title'
      },
      'value_lang' => { 'tag' => 'en-US' },
      'subtitle' => "But wait, there's more!"
    }
  end
  context '#assign_title' do
    it 'sets the title' do
      digital_object.assign_title('title' => new_title)
      expect(digital_object.title).to eq(new_title)
    end
  end

  context '#clean_title!' do
    let(:title_with_blanks_and_spaces) do
      {
        'value' => {
          'sort_portion' => '',
          'non_sort_portion' => '   Animal Farm   '
        },
        'value_lang' => { 'tag' => '' },
        'subtitle' => ''
      }
    end
    let(:clean_title) do
      {
        'value' => {
          'non_sort_portion' => 'Animal Farm'
        }
      }
    end

    it 'works as expected on the title instance variable' do
      digital_object.assign_title('title' => title_with_blanks_and_spaces)
      digital_object.clean_title!
      expect(digital_object.title).to eq(clean_title)
    end
  end
end
