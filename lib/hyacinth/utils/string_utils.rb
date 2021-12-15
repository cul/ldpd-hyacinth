module Hyacinth::Utils::StringUtils
  def self.ints_as_binstring(ints = [])
    stub = "".force_encoding(Encoding::ASCII_8BIT)
    ints.reduce(stub) { |m, c| m << c }
  end

  BOM_UTF_8 = ints_as_binstring([239, 187, 191])
  BOM_UTF_16BE = ints_as_binstring([254, 255])
  BOM_UTF_16LE = ints_as_binstring([255, 254])
  BOM_UTF_32BE = ints_as_binstring([0, 0, 254, 255])
  BOM_UTF_32LE = ints_as_binstring([255, 254, 0, 0])

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
    source_encoding = encoding_for_bom_indicator(source) || detected_encoding(source)
    source = trim_bom(source, source_encoding)
    if source.encoding == target_encoding
      # just the trim, thanks
      source
    else
      source = source.force_encoding(source_encoding) if source_encoding
      source.encode(target_encoding)
    end
  end

  def encoding_for_bom_indicator(source)
    magic_bytes = source.each_byte.lazy.first(4)
    magic_bytes = Hyacinth::Utils::StringUtils.ints_as_binstring(magic_bytes)
    # these codepoint patterns indicate unicode data in an ASCII_8 string
    case
    when magic_bytes.start_with?(BOM_UTF_16BE)
      source_encoding = Encoding::UTF_16BE
    when magic_bytes.start_with?(BOM_UTF_16LE)
      source_encoding = Encoding::UTF_16LE
    when magic_bytes.start_with?(BOM_UTF_8)
      source_encoding = Encoding::UTF_8
    when magic_bytes.start_with?(BOM_UTF_32BE)
      source_encoding = Encoding::UTF_32BE
    when magic_bytes.start_with?(BOM_UTF_32LE)
      source_encoding = Encoding::UTF_32LE
    end

    source_encoding
  end

  def detected_encoding(source)
    detection = CharlockHolmes::EncodingDetector.detect(source)
    detection[:encoding] ? Encoding.find(detection[:encoding]) : Encoding::ASCII_8BIT
  end

  def bom_prefix_for(encoding)
    case encoding
    when Encoding::UTF_16BE
      BOM_UTF_16BE
    when Encoding::UTF_16LE
      BOM_UTF_16LE
    when Encoding::UTF_8
      BOM_UTF_8
    when Encoding::UTF_32BE
      BOM_UTF_32BE
    when Encoding::UTF_32LE
      BOM_UTF_32LE
    end
  end

  def trim_bom(source, encoding)
    return source unless encoding
    prefix = bom_prefix_for(encoding)
    if prefix && source.byteslice(0...prefix.length).b == prefix
      source = source.byteslice(prefix.length..-1)
    end
    source
  end
end