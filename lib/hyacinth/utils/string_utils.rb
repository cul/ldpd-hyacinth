module Hyacinth::Utils::StringUtils

  def self.clean_utf8_string(str)
    # Weird character example that will fail in ruby: "\xC2".gsub('', '')
    return str.chars.select{|i| i.valid_encoding?}.join.gsub('','')
  end

  def self.replace_non_ascii_characters(str)
    # Replacing non-ASCII characters with '?' because ruby can't use string methods on some weird characters that STILL count as UTF-8.
    # Weird character example that will fail in ruby: "\xC2".gsub('', '')
    # \xC2 (used in the above example) is a control character.
    return str.encode('ASCII', :invalid => :replace, :undef => :replace)
  end

end