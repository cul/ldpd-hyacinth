require 'rails_helper'
require 'equivalent-xml'

context 'Hyacinth::Utils::HashUtils' do

  before(:all) do
  end

  before(:each) do
  end

  describe "::find_nested_hash_values" do
    
    it "works for top level keys in a simple hash" do
      hsh = {
        'a' => 'b',
        'c' => 'd',
        'e' => 'f'
      }
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'c')).to eq(['d'])
    end
    
    it "it dfferentiates between strings and symbols in a regular hash" do
      hsh = {
        'a' => 'y',
        :a => :z
      }
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'a')).to eq(['y'])
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, :a)).to eq([:z])
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
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'ccc')).to eq(['ddd'])
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
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'eee')).to eq(['fff'])
    end
    
    it "will return multiple" do
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
      expect(Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'name_role_value')).to eq(['Author', 'Illustrator', 'Photographer'])
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
      
      objects = Hyacinth::Utils::HashUtils::find_nested_hash_values(hsh, 'cc')
      objects.each_with_index do |obj, i|
        obj['value'] = 'change' + i.to_s
      end
      
      expect(hsh).to eq(expected)
    end
    
  end

end
