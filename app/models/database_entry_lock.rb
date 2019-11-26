# frozen_string_literal: true

class DatabaseEntryLock < ApplicationRecord
  attr_reader :lock_key
  attr_reader :created_at
  attr_reader :expires_at
end
