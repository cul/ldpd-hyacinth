# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '#new' do
    context 'when parameters correct' do
      let(:project) { FactoryBot.build(:project) }

      it 'creates a new project' do
        expect(project.save).to be true
      end

      it 'expect variables to be set correctly' do
        project.save
        expect(project.string_key).to eq 'great_project'
        expect(project.display_label).to eq 'Great Project'
        expect(project.project_url).to eq 'https://example.com/great_project'
      end
    end

    context 'when missing string_key' do
      let(:project) { FactoryBot.build(:project, string_key: nil) }

      it 'does not save' do
        expect(project.save).to be false
      end

      it 'returns correct error' do
        project.save
        expect(project.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when missing display_label' do
      let(:project) { FactoryBot.build(:project, display_label: nil) }

      it 'does not save' do
        expect(project.save).to be false
      end

      it 'returns correct error' do
        project.save
        expect(project.errors.full_messages).to include 'Display label can\'t be blank'
      end
    end

    context 'when display label not unique' do
      let(:display_label) { 'Best Project' }
      let(:project) { FactoryBot.build(:project, display_label: display_label, string_key: 'best_project') }

      before { FactoryBot.create(:project, display_label: display_label) }

      it 'does not save' do
        expect(project.save).to be false
      end

      it 'returns correct error' do
        project.save
        expect(project.errors.full_messages).to include 'Display label has already been taken'
      end
    end

    context 'when string_key not unique' do
      let(:string_key) { 'best_project' }
      let(:project) { FactoryBot.build(:project, string_key: string_key, display_label: 'Best Project') }

      before { FactoryBot.create(:project, string_key: string_key) }

      it 'does not save' do
        expect(project.save).to be false
      end

      it 'returns correct error' do
        project.save
        expect(project.errors.full_messages).to include 'String key has already been taken'
      end
    end
  end
end
