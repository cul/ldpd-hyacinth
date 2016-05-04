require 'rails_helper'

describe DigitalObject::FileSystem, :type => :model do
  describe '#initialize' do
    subject { described_class.new }
    it { expect(subject.dc_type).to eql('FileSystem') }
  end

  describe '#get_new_fedora_object' do
    let(:object) do
      object = described_class.new
      object.project = project
      object
    end
    let(:next_pid) { 'next:pid' }
    let(:project) do
      project = double(Project)
      allow(project).to receive(:next_pid).and_return(next_pid)
      project
    end
    subject { object.get_new_fedora_object }
    it { is_expected.to be_a Collection }
    it { expect(subject.pid).to eql(next_pid) }
  end

  describe '#publish' do
    let(:fedora_object) do
      fedora_object = double('FedoraObject')
      allow(fedora_object).to receive(:save)
      fedora_object
    end

    subject do
      subject = described_class.new
      subject.instance_variable_set :@fedora_object, fedora_object
      subject
    end

    it do
      pending("Pending: further implementation required")
      allow(subject).to receive(:publish_descriptions) # .and_return(subject)
      expect(subject).not_to receive(:publish_structures)
      subject.publish
    end
  end
end
