require 'rails_helper'

RSpec.describe User, :type => :model do
  describe "#can_manage_controlled_vocabulary_terms?" do
    context "nil parameter from index view" do
      let(:controlled_vocabulary) { nil }
      context "is admin" do
        subject { described_class.new(is_admin: true) }
        it { expect(subject.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)).to be true }
      end
      context "can manage all" do
        subject { described_class.new(can_manage_all_controlled_vocabularies: true) }
        it { expect(subject.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)).to be true }
      end
      context "is editor of project records" do
        let(:editable_projects) { ['awe'] }

        let(:relation) do
          result = double(:relation)
          allow(result).to receive(:where).and_return result
          allow(result).to receive(:pluck).and_return editable_projects
          result
        end

        before do
          allow(ProjectPermission).to receive(:where).and_return(relation)
        end

        subject { described_class.new }
        it { expect(subject.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)).to be false }
      end
    end
  end
end
