require 'rails_helper'

RSpec.describe Hyacinth::Utils::StringUtils do
  describe ".escape_four_byte_utf8_characters_as_html_entities" do
    {
      'only ascii characters here' => 'only ascii characters here',
      'some 3-byte characters here åéîøü' => 'some 3-byte characters here åéîøü',
      'some 4-byte characters here: 😄🎉🎃👍' => 'some 4-byte characters here: &#128516;&#127881;&#127875;&#128077;'
    }.each do |original, expected|
      it "generates the expected string" do
        expect(described_class.escape_four_byte_utf8_characters_as_html_entities(original)).to eq(expected)
      end
    end
  end
end
