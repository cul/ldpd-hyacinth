require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do
  
  describe "DynamicField concern" do
    
    describe "#update_dynamic_field_data" do
      it "merges existing dynamic_field_data with new data" do
    
        @digital_object = DigitalObject::Item.new()
    
        hsh1 = {
          "alternate_title" => [
            {
              "title_non_sort_portion" => "The",
              "title_sort_portion" => "Catcher in the Rye"
            },
            {
              "title_non_sort_portion" => "The",
              "title_sort_portion" => "Second Title"
            },
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
          "alternate_title" => [
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
          "alternate_title" => [
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
        @digital_object.update_dynamic_field_data(hsh1, false)
        expect(@digital_object.dynamic_field_data).to eq(hsh1)
    
        #Secondary set of data to merge
        @digital_object.update_dynamic_field_data(hsh2, true)
        expect(@digital_object.dynamic_field_data).to eq(merged_hsh)
    
      end
    
      it "overwrites all existing dynamic_field_data with new data when false argument is passed for merge param" do
        @digital_object = DigitalObject::Item.new()
    
        hsh1 = {
          "alternate_title" => [
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
        @digital_object.update_dynamic_field_data(hsh1, false)
        expect(@digital_object.dynamic_field_data).to eq(hsh1)
    
        #Secondary set of data to merge
        @digital_object.update_dynamic_field_data(hsh2, false)
        expect(@digital_object.dynamic_field_data).to eq(hsh2)
    
      end
      
    end
    
    describe "#remove_blank_fields_from_dynamic_field_data" do
      it "can recursively remove all blank fields from dynamic field data" do
    
        @digital_object = DigitalObject::Item.new()
    
        new_dynamic_field_data = {
          "alternate_title" => [
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
              "note_value" => "                         ", # A bunch of spaces
              "note_type" => ""
            }
          ]
        }
    
        expected = {
          "alternate_title" => [
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
    
        @digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        @digital_object.remove_blank_fields_from_dynamic_field_data!
        expect(@digital_object.dynamic_field_data).to eq(expected)
    
      end
    end
  
    describe "#remove_dynamic_field_data_key!" do
  
      it "can remove one or more specific keys, at varying levels, within the dynamic_field_data" do
  
        @digital_object = DigitalObject::Item.new()
  
        new_dynamic_field_data = {
          "alternate_title" => [
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
  
        @digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        @digital_object.remove_dynamic_field_data_key!('alternate_title')
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
  
        @digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        @digital_object.remove_dynamic_field_data_key!('name_role_value')
        expect(@digital_object.dynamic_field_data).to eq(expected)
      end
  
    end
    
    describe "#get_flattened_dynamic_field_data" do
      
      it "works as expected" do
        new_dynamic_field_data = {
          "alternate_title" => [
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
          ],
          "name" => [
            {
              "name_value" => "My name",
              "name_role" => [
                {
                  "name_role_value" => "Great Note"
                }
              ]
            }
          ]
        }
        
        flattened_dynamic_field_data = {
          'title_non_sort_portion' => ['The'],
          "title_sort_portion" => ["Catcher in the Rye"],
          "note_value" => ["My note", "My other note"],
          "note_type" => ["Great Note", "Really Great Note"],
          "name_value" => ["My name"],
          "name_role_value" => ["Great Note"]
        }
        
        @digital_object = DigitalObject::Item.new()
        @digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        
        expect(@digital_object.get_flattened_dynamic_field_data).to eq(flattened_dynamic_field_data)
        
      end
      
    end
    
  end

end
