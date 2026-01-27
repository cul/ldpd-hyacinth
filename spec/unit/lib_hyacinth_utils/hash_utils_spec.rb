require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Utils::HashUtils do
  describe ".find_nested_hash_values" do

    it "works for top level keys in a simple hash" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => 'f'
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'c')).to eq(['d'])
    end

    it "it dfferentiates between strings and symbols in a regular hash" do
      hsh = {
        'a' => 'y',
        :a => :z
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'a')).to eq(['y'])
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, :a)).to eq([:z])
    end

    it "works for deeply nested keys" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => {
          'aa' => 'bb',
          'cc' => 'dd',
          'ee' => {
            'aaa' => 'bbb',
            'ccc' => 'ddd',
            'eee' => 'fff'
          }
        }
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'ccc')).to eq(['ddd'])
    end

    it "can delve through mixed layers of hashes and arrays" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => [
          'x',
          'y',
          {
            'aa' => 'bb',
            'cc' => 'dd',
            'ee' => [
              {
                'aaa' => 'bbb',
                'ccc' => 'ddd',
                'eee' => 'fff'
              },
              'test',
              'another test'
            ]
          }
        ]
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'eee')).to eq(['fff'])
    end

    it "will return multiple results when present" do
      hsh = {
        'name' => [
          {
            'name_value' => 'Watson, Mary Jane',
            'name_role' => [
              {
                'name_role_value' => 'Author'
              },
              {
                'name_role_value' => 'Illustrator'
              }
            ]
          },
          {
            'name_value' => 'Parker, Peter',
            'name_role' => [
              {
                'name_role_value' => 'Photographer'
              }
            ]
          }
        ]
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'name_role_value')).to eq(['Author', 'Illustrator', 'Photographer'])
    end

    it "it returns elements by reference rather than making a copy of them" do
      hsh = {
        'a' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        },
        'b' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        },
        'c' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        }
      }

      expected = {
        'a' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change0'
          }
        },
        'b' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change1'
          }
        },
        'c' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change2'
          }
        }
      }

      objects = Hyacinth::Utils::HashUtils.find_nested_hash_values(hsh, 'cc')
      objects.each_with_index do |obj, i|
        obj['value'] = 'change' + i.to_s
      end

      expect(hsh).to eq(expected)
    end

  end

  describe ".find_nested_hashes_that_contain_key" do

    it "works for top level keys in a simple hash" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => 'f'
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'c')).to eq([hsh])
    end

    it "it dfferentiates between strings and symbols in a regular hash" do
      hsh = {
        'a' => 'y',
        :a => :z
      }
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'a')).to eq([hsh])
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, :a)).to eq([hsh])
    end

    it "works for deeply nested keys" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => {
          'aa' => 'bb',
          'cc' => 'dd',
          'ee' => {
            'aaa' => 'bbb',
            'ccc' => 'ddd',
            'eee' => 'fff'
          }
        }
      }
      expected = [{
        'aaa' => 'bbb',
        'ccc' => 'ddd',
        'eee' => 'fff'
      }]
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'ccc')).to eq(expected)
    end

    it "can delve through mixed layers of hashes and arrays" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => [
          'x',
          'y',
          {
            'aa' => 'bb',
            'cc' => 'dd',
            'ee' => [
              {
                'aaa' => 'bbb',
                'ccc' => 'ddd',
                'eee' => 'fff'
              },
              'test',
              'another test'
            ]
          }
        ]
      }
      expected = [{
        'aaa' => 'bbb',
        'ccc' => 'ddd',
        'eee' => 'fff'
      }]
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'eee')).to eq(expected)
    end

    it "will return multiple results when present" do
      hsh = {
        'name' => [
          {
            'name_value' => 'Watson, Mary Jane',
            'name_role' => [
              {
                'name_role_value' => 'Author'
              },
              {
                'name_role_value' => 'Illustrator'
              }
            ]
          },
          {
            'name_value' => 'Parker, Peter',
            'name_role' => [
              {
                'name_role_value' => 'Photographer'
              }
            ]
          }
        ]
      }

      expected = [
        {
          'name_role_value' => 'Author'
        },
        {
          'name_role_value' => 'Illustrator'
        },
        {
          'name_role_value' => 'Photographer'
        }
      ]
      expect(Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'name_role_value')).to eq(expected)
    end

    it "it returns elements by reference rather than making a copy of them" do
      hsh = {
        'a' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        },
        'b' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        },
        'c' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'original'
          }
        }
      }

      expected = {
        'a' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change0'
          }
        },
        'b' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change1'
          }
        },
        'c' => {
          'aa' => 'bb',
          'cc' => {
            'value' => 'change2'
          }
        }
      }

      objects = Hyacinth::Utils::HashUtils.find_nested_hashes_that_contain_key(hsh, 'value')
      objects.each_with_index do |obj, i|
        obj['value'] = 'change' + i.to_s
      end

      expect(hsh).to eq(expected)
    end
  end

  describe ".recursively_remove_blank_fields_from_hash!" do
    it "modifies the given hash and recursively removes all blank fields" do
      hsh = {
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
        "controlled_field_group" => [
          {
            "controlled_field" =>  {
              "controlled_field_uri" => "",
              "controlled_field_value" => "",
            }
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

      described_class.recursively_remove_blank_fields_from_hash!(hsh)
      expect(hsh).to eq(expected)
    end
  end

  describe ".recursively_remove_blank_fields_from_hash" do
    it "returns a new hash with all blank fields recursively removed, and does not modify the original hash" do
      hsh = {
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
        "controlled_field_group" => [
          {
            "controlled_field" =>  {
              "controlled_field_uri" => "",
              "controlled_field_value" => "",
            }
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

      new_hsh = described_class.recursively_remove_blank_fields_from_hash(hsh)
      # New hash should have blank values recursively removed
      expect(new_hsh).to eq(expected)
      # New hash should not equal old hash, since old hash should not have been modified
      expect(new_hsh).not_to eq(hsh)
    end
  end
end
