# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Rights do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }

  context '#clean_rights!' do
    let(:rights) do
      {
        'descriptiveMetadata' => [
          {
            'typeOfContent' => '  compilation ',
            'countryOfOrigin' => nil,
            'filmDistributedToPublic' => nil,
            "filmDistributedCommercially" => nil
          }
        ],
        'copyrightStatus' => [
          {
            'copyrightNote' => '   ',
            'copyrightRegistered' => true,
            'copyrightRenewed' => false,
            'copyrightDateOfRenewal' => '',
            'copyrightExpirationDate' => '',
            'culCopyrightAssessmentDate' => ''
          }
        ]
      }
    end
    let(:cleaned_rights) do
      {
        'descriptiveMetadata' => [
          {
            'typeOfContent' => 'compilation'
          }
        ],
        'copyrightStatus' => [
          {
            'copyrightRegistered' => true
          }
        ]
      }
    end

    it 'works as expected on dynamic_field_data instance variable' do
      digital_object_with_sample_data.assign_rights('rights' => rights)
      digital_object_with_sample_data.clean_rights!
      expect(digital_object_with_sample_data.rights).to eq(cleaned_rights)
    end
  end
end
