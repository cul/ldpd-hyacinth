module Hyacinth::Utils::StringUtils
  def self.string_valid_utf8?(str)
    # Let's start off by asserting that this is a utf-8 string (regardless of whether or not it is).
    # Note that we are duplicating the string because we do not want to modify the passed-in value.
    str_with_utf8_assertion = str.dup.force_encoding('utf-8')
    # Check if this string, which we are asserting is utf-8, only contains valid utf-8 characters.
    str_with_utf8_assertion.valid_encoding?
  end

  def self.file_valid_utf8?(file_path)
    content = File.binread(file_path)
    string_valid_utf8?(content)
  end

  # There are some characters that are technically UTF-8, but that cause errors when string containing these characters
  # are passed to certain string processing methods (like gsub).  This method removes those characters and returns a
  # "clean" utf-8 string. Example cleaning: clean_utf8_string("abc\xC2abc") outputs "abcabc"
  # NOTE: "\xC2", in the above example, is a control character.
  # NOTE: This method was originally added when Hyacinth was running Ruby 2.4.  A lot has changed in newer versions
  # of Ruby, so we should one day re-evaluate whether it's necessary.
  def self.clean_utf8_string(str)
    str.chars.select(&:valid_encoding?).join.gsub('', '')
  end

  # # There are some characters that are technically UTF-8, but that cause errors when string containing these characters
  # # are passed to certain string processing methods (like gsub).  This method removes those characters and replaces them
  # # with a "?" character. Example: replace_non_ascii_characters("abc\xC2abc") outputs "abc?abc"
  # # NOTE: "\xC2", in the above example, is a control character.
  # # NOTE: This method was originally added when Hyacinth was running Ruby 2.4.  A lot has changed in newer versions
  # # of Ruby, so we should one day re-evaluate whether it's necessary.
  # def self.replace_non_ascii_characters(str)
  #   str.encode('ASCII', invalid: :replace, undef: :replace)
  # end

  def self.escape_four_byte_utf8_characters_as_html_entities(str)
    str.gsub(/[\u{10000}-\u{10ffff}]/) { |mb4| "&#x#{mb4.ord.to_s(16)};" }
  end
end
