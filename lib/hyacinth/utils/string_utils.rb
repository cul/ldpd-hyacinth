module Hyacinth::Utils::StringUtils
  def self.ints_as_binstring(ints = [])
    stub = "".force_encoding(Encoding::ASCII_8BIT)
    ints.inject(stub) { |m,c| m << c }
  end

  BOM_UTF_8 = ints_as_binstring([239,187,191])
  BOM_UTF_16BE = ints_as_binstring([254,255])
  BOM_UTF_16LE = ints_as_binstring([255,254])
  BOM_UTF_32BE = ints_as_binstring([0,0,254,255])
  BOM_UTF_32LE = ints_as_binstring([255,254,0,0])

  def self.clean_utf8_string(str)
    # Weird character example that will fail in ruby: "\xC2".gsub('', '')
    str.chars.select(&:valid_encoding?).join.gsub('', '')
  end

  def self.replace_non_ascii_characters(str)
    # Replacing non-ASCII characters with '?' because ruby can't use string methods on some weird characters that STILL count as UTF-8.
    # Weird character example that will fail in ruby: "\xC2".gsub('', '')
    # \xC2 (used in the above example) is a control character.
    str.encode('ASCII', invalid: :replace, undef: :replace)
  end

  def encoded_string(source, target_encoding = Encoding::UTF_8)
    magic_bytes = source.each_byte.lazy.first(4)
    magic_bytes = Hyacinth::Utils::StringUtils.ints_as_binstring(magic_bytes)
    return source if source.encoding == target_encoding
    # these codepoint patterns indicate unicode data in an ASCII_8 string
    case
    when magic_bytes.start_with?(BOM_UTF_16BE)
      source_encoding = Encoding::UTF_16BE
      source = source.byteslice(BOM_UTF_16BE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_16LE)
      source_encoding = Encoding::UTF_16LE
      source = source.byteslice(BOM_UTF_16LE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_8)
      source_encoding = Encoding::UTF_8
      source = source.byteslice(BOM_UTF_8.length..-1)
    when magic_bytes.start_with?(BOM_UTF_32BE)
      source_encoding = Encoding::UTF_32BE
      source = source.byteslice(BOM_UTF_32BE.length..-1)
    when magic_bytes.start_with?(BOM_UTF_32LE)
      source_encoding = Encoding::UTF_32LE
      source = source.byteslice(BOM_UTF_32LE.length..-1)
    else
      detection = CharlockHolmes::EncodingDetector.detect(source)
      source_encoding = detection[:encoding] ?
        Encoding.find(detection[:encoding]) : Encoding::ASCII_8BIT
    end
    if source.encoding == target_encoding
      # just the trim, thanks
      source
    else
      source.force_encoding(source_encoding).encode(target_encoding)
    end
  end
end
