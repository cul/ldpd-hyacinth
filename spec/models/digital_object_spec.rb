require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  it "has a default dynamic_field_data value of {}" do
    @digital_object = DigitalObject::Item.new()
    expect(@digital_object.dynamic_field_data).to eq({})
  end

  it "properly merges existing dynamic_field_data with new data (via update_dynamic_field_data method)" do

    @digital_object = DigitalObject::Item.new()

    hsh1 = {
      "title" => [
        {
          "title_non_sort_portion" => "The",
          "title_sort_portion" => "Catcher in the Rye"
        }
      ],
      "collection" => [
        {
          "collection_authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "note_value" => "Test",
          "note_type" => "Custom"
        }
      ]
    }

    hsh2 = {
      "title" => [
        {
          "title_sort_portion" => "Some Catcher in Some Rye"
        }
      ],
      "note" => [
        {
          "note_value" => "Great Note",
          "note_type" => "Great"
        },
        {
          "note_value" => "Awesome Note",
          "note_type" => "Awesome"
        }
      ]
    }

    merged_hsh = {
      "title" => [
        {
          "title_sort_portion" => "Some Catcher in Some Rye"
        }
      ],
      "collection" => [
        {
          "collection_authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "note_value" => "Great Note",
          "note_type" => "Great"
        },
        {
          "note_value" => "Awesome Note",
          "note_type" => "Awesome"
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

  it "overwrites existing dynamic_field_data with new data (via update_dynamic_field_data method with false argument)" do
    @digital_object = DigitalObject::Item.new()

    hsh1 = {
      "title" => [
        {
          "title_non_sort_portion" => "The",
          "title_sort_portion" => "Catcher in the Rye"
        }
      ],
      "collection" => [
        {
          "collection_authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ]
    }

    hsh2 = {
      "note" => [
        {
          "note_value" => "Test",
          "note_type" => "Custom"
        }
      ]
    }

    #Initial set of data
    @digital_object.update_dynamic_field_data(hsh1)
    expect(@digital_object.dynamic_field_data).to eq(hsh1)

    #Secondary set of data to merge
    @digital_object.update_dynamic_field_data(hsh2, false)
    expect(@digital_object.dynamic_field_data).to eq(hsh2)

  end

  it "can remove blank fields from dynamic field data (via remove_blank_fields_from_dynamic_field_data! method)" do

    @digital_object = DigitalObject::Item.new()

    new_dynamic_field_data = {
      "title" => [
        {
          "title_non_sort_portion" => "",
          "title_sort_portion" => "Catcher in the Rye"
        }
      ],
      "name" => [
        {
          "name_value" => "",
          "name_role" => [
            {
              "name_role_value" => ""
            }
          ]
        }
      ],
      "collection" => [
        {
          "collection_authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ],
      "note" => [
        {
          "note_value" => "",
          "note_type" => ""
        }
      ]
    }

    expected = {
      "title" => [
        {
          "title_sort_portion" => "Catcher in the Rye"
        }
      ],
      "collection" => [
        {
          "collection_authorized_term_uri" => "http://localhost:8080/fedora/objects/cul:p5hqbzkh2p"
        }
      ]
    }

    @digital_object.update_dynamic_field_data(new_dynamic_field_data)
    @digital_object.remove_blank_fields_from_dynamic_field_data!
    expect(@digital_object.dynamic_field_data).to eq(expected)

  end

  describe "#remove_dynamic_field_data_key!" do

    it "can remove one or more specific keys, at varying levels, within the dynamic_field_data" do

      @digital_object = DigitalObject::Item.new()

      new_dynamic_field_data = {
        "title" => [
          {
            "title_non_sort_portion" => "The",
            "title_sort_portion" => "Catcher in the Rye"
          }
        ],
        "note" => [
          {
            "note_value" => "My note",
            "note_type" => "Great Note"
          },
          {
            "note_value" => "My other note",
            "note_type" => "Really Great Note"
          }
        ]
      }

      expected = {
        "note" => [
          {
            "note_value" => "My note",
          },
          {
            "note_value" => "My other note",
          }
        ]
      }

      @digital_object.update_dynamic_field_data(new_dynamic_field_data)
      @digital_object.remove_dynamic_field_data_key!('title')
      @digital_object.remove_dynamic_field_data_key!('note_type')
      expect(@digital_object.dynamic_field_data).to eq(expected)
    end

    it "clears empty parent elements after perfoming a key deletion" do

      @digital_object = DigitalObject::Item.new()

      new_dynamic_field_data = {
        "name" => [
          {
            "name_value" => "Smith, John",
            "name_role" => [
              {
                "name_role_value" => "Creator"
              }
            ]
          }
        ]
      }

      expected = {
        "name" => [
          {
            "name_value" => "Smith, John",
          }
        ]
      }

      @digital_object.update_dynamic_field_data(new_dynamic_field_data)
      @digital_object.remove_dynamic_field_data_key!('name_role_value')
      expect(@digital_object.dynamic_field_data).to eq(expected)
    end

  end





end
