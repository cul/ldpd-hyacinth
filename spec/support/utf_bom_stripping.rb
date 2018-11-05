RSpec.shared_context "utf bom example source" do
  let(:utf8_source) do
    codepoints = [81,58,32,84,104,105,115,32,105,115,32,77,121,114,195,182,110]
    seed = ""
    seed.force_encoding(Encoding::ASCII_8BIT)
    codepoints.inject(seed) { |m,c| m << c }
  end
  let(:utf8_target) { "Q: This is Myrön".encode(Encoding::UTF_8) }
end
RSpec.shared_examples "strips BOM and returns UTF8" do
  subject { described_class.new.encoded_string(input_source) }
  # it is UTF8
  it { expect(subject.encoding).to eql(Encoding::UTF_8) }
  # it removes the BOM
  it { expect(subject.codepoints).to eql(utf8_target.codepoints) }
end