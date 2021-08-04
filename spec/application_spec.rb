# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::Application do
  describe 'application-wide time zone rules' do
    let(:expected_time_zone_name) { described_class.config.time_zone }

    it 'has the expected time zone set' do
      expect(Time.zone.name).to eq(expected_time_zone_name)
      expect(Time.current.time_zone.name).to eq(expected_time_zone_name)
    end

    context 'ActiveRecord date behavior' do
      let(:project) { FactoryBot.create(:project) }

      it 'on save, sets the created_at time using the expected time zone' do
        expect(project.created_at.time_zone.name).to eq(expected_time_zone_name)
      end

      it 'stores the time as UTC in the database' do
        local_date_in_utc = project.created_at.getutc
        db_date_value_string = ActiveRecord::Base.connection.execute("SELECT created_at FROM projects WHERE id = #{project.id}").first['created_at']

        # Date from DB won't have a time zone indicator.  We'll parse it as UTC.
        parsed_date_from_db_value = ActiveSupport::TimeZone.new('UTC').parse(db_date_value_string)

        expect(local_date_in_utc.strftime('%H:%M')).to eq(parsed_date_from_db_value.strftime('%H:%M'))
      end
    end
  end
end
