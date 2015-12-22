require "rails_helper"

describe 'projects/dynamic_fields/edit.html.erb', type: :view do
  let(:project) do
    _p = Project.new(id: 1, display_label: "Display Label", string_key: "stringKey")
    allow(_p).to receive(:new_record?).and_return(false)
    _p
  end
  let(:digital_object_type) do
    _dot = DigitalObjectType.new(id: 1, display_label: "Item", string_key: "item")
    allow(_dot).to receive(:new_record?).and_return(false)
    _dot
  end
  before do
    assign(:project, project)
    assign(:digital_object_type, digital_object_type)
    render
  end
  subject { rendered }
  it { is_expected.to have_selector "form[action='/projects/1/dynamic_fields?digital_object_type_id=1']" }
end
