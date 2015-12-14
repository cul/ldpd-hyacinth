require "rails_helper"

describe 'projects/dynamic_fields/edit.html.erb', type: :view do
  let(:project) do
    _p = Project.new(id: 1, display_label: "Display Label", string_key: "stringKey")
    allow(_p).to receive(:new_record?).and_return(false)
    _p
  end
  before do
    assign(:project, project)
    render
  end
  subject { rendered }
  it { is_expected.to have_selector "form[action='/projects/1/dynamic_fields']" }
end
