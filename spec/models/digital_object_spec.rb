require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  it "properly merges existing dynamic_field_data with new data (via update_dynamic_field_data method)" do

    @digital_object = DigitalObject::Item.new()
    expect(@digital_object.dynamic_field_data).to eq({})

    hsh1 = {
      "title" => [
        {
          "non_sort_portion" => "The",
          "sort_portion" => "Catcher in the Rye"
        }
      ],
      "collection" => [
        {
          "authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "value" => "Test",
          "type" => "Custom"
        }
      ]
    }

    hsh2 = {
      "title" => [
        {
          "sort_portion" => "Some Catcher in Some Rye"
        }
      ],
      "note" => [
        {
          "value" => "Great Note",
          "type" => "Great"
        },
        {
          "value" => "Awesome Note",
          "type" => "Awesome"
        }
      ]
    }

    merged_hsh = {
      "title" => [
        {
          "sort_portion" => "Some Catcher in Some Rye"
        }
      ],
      "collection" => [
        {
          "authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "value" => "Great Note",
          "type" => "Great"
        },
        {
          "value" => "Awesome Note",
          "type" => "Awesome"
        }
      ]
    }

    #Initial set of data
    @digital_object.update_dynamic_field_data(hsh1)
    expect(@digital_object.dynamic_field_data).to eq(hsh1)

    #Secondary set of data to merge
    @digital_object.update_dynamic_field_data(hsh2)
    expect(@digital_object.dynamic_field_data).to eq(merged_hsh)

  end

  it "can remove blank fields from dynamic field data (via remove_blank_fields_from_dynamic_field_data! method)" do

    @digital_object = DigitalObject::Item.new()

    new_dynamic_field_data = {
      "title" => [
        {
          "non_sort_portion" => "",
          "sort_portion" => "Catcher in the Rye"
        }
      ],
      "name" => [
        {
          "value" => "",
          "role" => [
            {
              "value" => ""
            }
          ]
        }
      ],
      "collection" => [
        {
          "authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "value" => "",
          "type" => ""
        }
      ]
    }

    expected = {
      "title" => [
        {
          "sort_portion" => "Catcher in the Rye"
        }
      ],
      "collection" => [
        {
          "authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ]
    }

    @digital_object.update_dynamic_field_data(new_dynamic_field_data)
    @digital_object.remove_blank_fields_from_dynamic_field_data!
    expect(@digital_object.dynamic_field_data).to eq(expected)

  end



end
