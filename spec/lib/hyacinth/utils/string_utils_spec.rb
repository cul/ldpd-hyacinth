require 'rails_helper'

RSpec.describe Hyacinth::Utils::StringUtils do
  let(:special_chars_csv_utf8_string) { "This string is utf-8.  すごい!  And this is pizza: 🍕" }
  let(:special_chars_csv_latin1_string) {
    "áéîøü.  This string is encoded as Latin-1 (ISO-8859-1).  It contains some non-ASCII characters.".encode('ISO-8859-1')
  }

  let(:special_chars_csv_utf8_file) { fixture('sample_digital_object_data/special_char_csv_fixtures/special_chars_csv_utf8.csv') }
  let(:special_chars_csv_latin1_file) { fixture('sample_digital_object_data/special_char_csv_fixtures/special_chars_csv_latin1.csv') }

  describe ".string_valid_utf8?" do
    it "returns true for utf-8 string content" do
      expect(described_class.string_valid_utf8?(special_chars_csv_utf8_string)).to eq(true)
    end

    it "returns false for NON-utf-8 string content" do
      expect(described_class.string_valid_utf8?(special_chars_csv_latin1_string)).to eq(false)
    end
  end

  describe ".file_valid_utf8?" do
    it "returns true for a utf-8 encoded file" do
      expect(described_class.file_valid_utf8?(special_chars_csv_utf8_file.path)).to eq(true)
    end

    it "returns false for a NON-utf-8 encoded file" do
      expect(described_class.file_valid_utf8?(special_chars_csv_latin1_file.path)).to eq(false)
    end
  end

  describe ".escape_four_byte_utf8_characters_as_html_entities" do
    {
      'only ascii characters here' => 'only ascii characters here',
      'some 3-byte characters here åéîøü' => 'some 3-byte characters here åéîøü',
      'some 4-byte characters here: 😄🎉🎃👍' => 'some 4-byte characters here: &#x1f604;&#x1f389;&#x1f383;&#x1f44d;',
      'this is the lowest value 4-byte utf8 string: 𐀀' => 'this is the lowest value 4-byte utf8 string: &#x10000;'
    }.each do |original, expected|
      it "generates the expected string" do
        expect(described_class.escape_four_byte_utf8_characters_as_html_entities(original)).to eq(expected)
      end

      it "generates an encoded string that can be easily converted back into the original value" do
        expect(CGI.unescape_html(
          described_class.escape_four_byte_utf8_characters_as_html_entities(original)
        )).to eq(original)
      end
    end
  end
end
