require 'rails_helper'

describe DigitalObject::DynamicField, :type => :unit do
  let(:test_class) do
    _c = Class.new
    _c.send :include, DigitalObject::DynamicField
  end

  let(:digital_object) { test_class.new }

  describe "DynamicField concern" do
    describe "#update_dynamic_field_data" do
      it "merges existing dynamic_field_data with new data" do
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
        digital_object.update_dynamic_field_data(hsh1, false)
        expect(digital_object.dynamic_field_data).to eq(hsh1)

        #Secondary set of data to merge
        digital_object.update_dynamic_field_data(hsh2, true)
        expect(digital_object.dynamic_field_data).to eq(merged_hsh)
      end

      it "overwrites all existing dynamic_field_data with new data when false argument is passed for merge param" do
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
        digital_object.update_dynamic_field_data(hsh1, false)
        expect(digital_object.dynamic_field_data).to eq(hsh1)

        #Secondary set of data to merge
        digital_object.update_dynamic_field_data(hsh2, false)
        expect(digital_object.dynamic_field_data).to eq(hsh2)
      end

      it "throws an exception if the dynamic field data contains invalid UTF-8 characters" do
        dfd = {
          "some_field" => [
            {
              # Note: The sequence below is an opening Windows-1252 smart quote, followed by "ABC",
              # followed by another closing Windows-1252 smart quote.  The smart quote characters
              # do not properly convert to UTF-8 and will result in UTF-8 parsing errors.
              "value_with_invalid_utf8_field" => [0x93, 65, 66, 67, 0x94].pack('c*')
            }
          ],
        }

        expect { digital_object.update_dynamic_field_data(dfd, false) }.to raise_error(
          Hyacinth::Exceptions::InvalidUtf8DetectedError,
          /Invalid UTF-8 detected/
        )
      end
    end

    describe "#trim_whitespace_and_clean_control_characters_for_dynamic_field_data!" do
      it "can recursively trim whitespace in dynamic field data" do
        new_dynamic_field_data = {
          "alternate_title" => [
            {
              "title_non_sort_portion" => "No Extra Spaces",
              "title_sort_portion" => "    Catcher in the Rye    "
            }
          ],
          "name" => [
            {
              "name_value" => " This has space ",
              "name_role" => [
                {
                  "name_role_value" => " This value has spaaaace     "
                },
                {
                  "name_role_value" => "Unchanged role without extra space"
                }
              ]
            }
          ],
          "some_field_group" => [
            {
              "some_field" => "Great value here",
              "controlled_field" =>  {
                "controlled_field_uri" => "        http://id.library.columbia.edu/with/leading/space",
                "controlled_field_value" => "Value with trailing space       ",
              }
            }
          ]
        }

        expected = {
          "alternate_title" => [
            {
              "title_non_sort_portion" => "No Extra Spaces",
              "title_sort_portion" => "Catcher in the Rye"
            }
          ],
          "name" => [
            {
              "name_value" => "This has space",
              "name_role" => [
                {
                  "name_role_value" => "This value has spaaaace"
                },
                {
                  "name_role_value" => "Unchanged role without extra space"
                }
              ]
            }
          ],
          "some_field_group" => [
            {
              "some_field" => "Great value here",
              "controlled_field" =>  {
                "controlled_field_uri" => "http://id.library.columbia.edu/with/leading/space",
                "controlled_field_value" => "Value with trailing space",
              }
            }
          ]
        }

        digital_object.trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(new_dynamic_field_data)
        expect(new_dynamic_field_data).to eq(expected)
      end

      it "cleans control characters that are NOT tab, new line, or carriage return" do
        new_dynamic_field_data = {
          "example_field_1" => [
            { "example_field_1_value" => "Control characters \t\r\n in the middle of the string that should be kept" }
          ],
          "example_field_2" => [
            { "example_field_2_value" => "And some other control characters #{[7].pack('c*')} that should be removed #{[27].pack('c*')} because they're not useful in Hyacinth" }
          ],
          "example_field_3" => [
            { "example_field_3_value" => "This line has a mix of control characters to keep (\n) and to remove (#{[27].pack('c*')})" }
          ]
        }

        expected = {
          "example_field_1" => [
            { "example_field_1_value" => "Control characters \t\r\n in the middle of the string that should be kept" }
          ],
          "example_field_2" => [
            { "example_field_2_value" => "And some other control characters  that should be removed  because they're not useful in Hyacinth" }
          ],
          "example_field_3" => [
            { "example_field_3_value" => "This line has a mix of control characters to keep (\n) and to remove ()" }
          ]
        }
        digital_object.trim_whitespace_and_clean_control_characters_for_dynamic_field_data!(new_dynamic_field_data)
        expect(new_dynamic_field_data).to eq(expected)
      end
    end

    describe "#remove_dynamic_field_data_key!" do
      it "can remove one or more specific keys, at varying levels, within the dynamic_field_data" do
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

        digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        digital_object.remove_dynamic_field_data_key!('alternate_title')
        digital_object.remove_dynamic_field_data_key!('note_type')
        expect(digital_object.dynamic_field_data).to eq(expected)
      end

      it "clears empty parent elements after perfoming a key deletion" do
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

        digital_object.update_dynamic_field_data(new_dynamic_field_data, false)
        digital_object.remove_dynamic_field_data_key!('name_role_value')
        expect(digital_object.dynamic_field_data).to eq(expected)
      end
    end

    describe ".recursively_generate_flattened_dynamic_field_data" do
      it "works as expected" do
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

        expect(DigitalObject::Base.recursively_generate_flattened_dynamic_field_data(new_dynamic_field_data)).to eq(flattened_dynamic_field_data)
      end
    end

    describe ".recursively_generate_csv_style_flattened_dynamic_field_data" do
      let(:flattened_csv_style_dynamic_field_data) do
        {
          'title-1:title_non_sort_portion' => 'The',
          'title-1:title_sort_portion' => 'Catcher in the Rye',
          'note-1:note_value' => 'My note',
          'note-1:note_type' => 'Great Note',
          'note-2:note_value' => 'My other note',
          'note-2:note_type' => 'Really Great Note',
          'name-1:name_note' => 'A note about this name',
          'name-1:name_term.uri' => 'http://id.library.columbia.edu/term/123',
          'name-1:name_term.value' => 'Smith, John',
          'name-1:name_role-1:name_role_term.uri' => 'http://id.library.columbia.edu/term/222',
          'name-1:name_role-1:name_role_term.value' => 'Author',
          'name-1:name_role-2:name_role_term.uri' => 'http://id.library.columbia.edu/term/333',
          'name-1:name_role-2:name_role_term.value' => 'Illustrator',
          'name-2:name_note' => 'A different name note',
          'name-2:name_term.uri' => 'http://id.library.columbia.edu/term/456',
          'name-2:name_term.value' => 'Garfield',
          'name-2:name_role-1:name_role_term.uri' => 'http://id.library.columbia.edu/term/444',
          'name-2:name_role-1:name_role_term.value' => 'Editor',
          'name-2:name_role-2:name_role_term.uri' => 'http://id.library.columbia.edu/term/555',
          'name-2:name_role-2:name_role_term.value' => 'Composer'
        }
      end

      let(:new_dynamic_field_data) do
        {
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
          ],
          "name" => [
            {
              "name_note" => "A note about this name",
              "name_term" => {
                "uri" => "http://id.library.columbia.edu/term/123",
                "value" => "Smith, John"
              },
              "name_role" => [
                {
                  "name_role_term" => {
                    "uri" => "http://id.library.columbia.edu/term/222",
                    "value" => "Author"
                  }
                },
                {
                  "name_role_term" => {
                    "uri" => "http://id.library.columbia.edu/term/333",
                    "value" => "Illustrator"
                  }
                }
              ]
            },
            {
              "name_note" => "A different name note",
              "name_term" => {
                "uri" => "http://id.library.columbia.edu/term/456",
                "value" => "Garfield"
              },
              "name_role" => [
                {
                  "name_role_term" => {
                    "uri" => "http://id.library.columbia.edu/term/444",
                    "value" => "Editor"
                  }
                },
                {
                  "name_role_term" => {
                    "uri" => "http://id.library.columbia.edu/term/555",
                    "value" => "Composer"
                  }
                }
              ]
            }
          ]
        }
      end

      it "works as expected" do
        expect(test_class.recursively_generate_csv_style_flattened_dynamic_field_data(new_dynamic_field_data)).to eq(flattened_csv_style_dynamic_field_data)
      end
      context "only the keys" do
        let(:test_class) do
          _c = Class.new
          _c.send :include, Hyacinth::Csv::Flatten
        end
        subject { test_class.new.keys_for_document('dynamic_field_data' => new_dynamic_field_data) }
        it { is_expected.to eql(flattened_csv_style_dynamic_field_data.keys)}
      end
    end
  end
end
