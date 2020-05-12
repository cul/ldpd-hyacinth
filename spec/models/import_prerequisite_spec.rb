# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportPrerequisite, type: :model do
  describe '#new' do
    subject(:import_prerequisite) { FactoryBot.create(:import_prerequisite) }

    it { is_expected.to be_a ImportPrerequisite }
    its(:batch_import) { is_expected.to be_a BatchImport }
    its(:digital_object_import) { is_expected.to be_a DigitalObjectImport }
    its(:prerequisite_digital_object_import) { is_expected.to be_a DigitalObjectImport }

    context "required fields" do
      it "requires batch_import" do
        expect { FactoryBot.create(:import_prerequisite, batch_import: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "requires digital_object_import" do
        expect { FactoryBot.create(:import_prerequisite, digital_object_import: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "requires prerequisite_digital_object_import_id" do
        expect { FactoryBot.create(:import_prerequisite, prerequisite_digital_object_import: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
