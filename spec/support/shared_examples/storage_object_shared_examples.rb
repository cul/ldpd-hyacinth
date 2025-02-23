RSpec.shared_examples "storage object" do
  describe "required methods" do
    required_methods = [:exist?, :filename, :size, :content_type, :read, :write]

    required_methods.each do |required_method|
      it "#{described_class.name} implements ##{required_method}" do
        # `instance_methods(false)` means instance methods defined ON this class (and not inherited)
        expect(described_class.instance_methods(false)).to include(required_method)
      end
    end
  end
end
