require 'rails_helper'
require 'shared_examples/lock_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::LockAdapter::DatabaseEntryLock do
  let(:adapter) { described_class.new(lock_timeout: 5.minutes) }
  it_behaves_like "a lock adapter"

  context "creation and deletion" do
    let(:key) { 'some_key' }
    let(:lock_timeout) { 1.minute }
    let(:expires_at) { DateTime.current + lock_timeout }
    it "works" do
      # TODO: Delete this test
      database_entry_lock = DatabaseEntryLock.create!(lock_key: key, expires_at: expires_at)
      expect(database_entry_lock.new_record?).to eq(false)
    end
  end

  context "#with_lock" do
    let(:key) { 'some_key' }
    it "yields the expected value" do
      expect { |b| adapter.with_lock(key, &b) }.to yield_with_args(Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject)
    end
  end

  context "#with_multilock" do
    let(:key1) { 'some_key1' }
    let(:key2) { 'some_key2' }
    let(:key3) { 'some_key3' }
    it "yields the expected value" do
      expect { |b| adapter.with_multilock([key1, key2, key3], &b) }.to yield_with_args(Hash)
      adapter.with_multilock([key1, key2, key3]) do |lock_objects|
        expect(lock_objects.size).to be(3)

        expect(lock_objects.key?(key1)).to be(true)
        expect(lock_objects.key?(key2)).to be(true)
        expect(lock_objects.key?(key3)).to be(true)

        expect(lock_objects[key1]).to be_a(Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject)
        expect(lock_objects[key2]).to be_a(Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject)
        expect(lock_objects[key3]).to be_a(Hyacinth::Adapters::LockAdapter::DatabaseEntryLock::LockObject)
      end
    end
  end
end
