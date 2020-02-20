# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchImport, type: :model do
  describe '#new' do
    subject(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }

    it { is_expected.to be_a BatchImport }
    its(:priority)      { is_expected.to eql 'high' }
    its(:status)        { is_expected.to eql 'in_progress' }
    its(:user)          { is_expected.to be_a User }
    its(:file_location) { 'managed-disk://path/to/file' }

    its('digital_object_imports.length') { is_expected.to be 1 }
  end

  describe '#delete_associated_file' do
    let(:file_location) { Tempfile.new(['temp', '.csv']).path }
    let(:batch_import) { FactoryBot.create(:batch_import, file_location: "managed-disk://#{file_location}") }

    it 'runs after object destroy' do
      expect(batch_import).to receive(:delete_associated_file)
      batch_import.destroy
    end

    it 'successfully deletes the associated file' do
      expect(File.exist?(file_location)).to be true
      batch_import.delete_associated_file
      expect(File.exist?(file_location)).to be false
    end
  end

  describe '#import_count' do
    let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }

    before do
      FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
    end

    it "returns 0 when counting failure imports" do
      expect(batch_import.import_count('failure')).to be 0
    end

    it "returns 1 when counting successful imports" do
      expect(batch_import.import_count('success')).to be 1
    end

    it "returns 1 when counting pending imports" do
      expect(batch_import.import_count('pending')).to be 1
    end

    it "returns 2 when counting in progress imports" do
      expect(batch_import.import_count('in_progress')).to be 2
    end
  end
end
