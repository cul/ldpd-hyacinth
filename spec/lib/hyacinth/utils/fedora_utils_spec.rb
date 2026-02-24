require 'rails_helper'

RSpec.describe Hyacinth::Utils::FedoraUtils do
  describe ".find_object_pid_by_filesystem_path" do
    it "escapes single quotes in file paths" do
      full_filesystem_path = %q(/some/path/cool-o'something-irish-filename.pdf)
      escaped_full_filesystem_path = %q(/some/path/cool-o\\'something-irish-filename.pdf)

      # return value of .find_by_itql doesn't actually matter for this test
      expect(Cul::Hydra::Fedora.repository).to receive(:find_by_itql).with(
        "select $pid from <#ri> where $pid <http://purl.org/dc/elements/1.1/source> '#{escaped_full_filesystem_path}'"\
        " and $pid <info:fedora/fedora-system:def/model#state> <fedora-model:Active>",
        { type: 'tuples', format: 'json', limit: '', stream: 'on', flush: 'true' }
      ).and_return(JSON.generate({'results' => []}))

      described_class.find_object_pid_by_filesystem_path(full_filesystem_path)
    end

    it "does not include an active item filter when active_only param is set to false" do
      full_filesystem_path = %q(/some/path/cool-o'something-irish-filename.pdf)
      escaped_full_filesystem_path = %q(/some/path/cool-o\\'something-irish-filename.pdf)

      # return value of .find_by_itql doesn't actually matter for this test
      expect(Cul::Hydra::Fedora.repository).to receive(:find_by_itql).with(
        "select $pid from <#ri> where $pid <http://purl.org/dc/elements/1.1/source> '#{escaped_full_filesystem_path}'",
        { type: 'tuples', format: 'json', limit: '', stream: 'on', flush: 'true' }
      ).and_return(JSON.generate({'results' => []}))

      described_class.find_object_pid_by_filesystem_path(full_filesystem_path, false)
    end
  end

  describe '.escape_path_or_uri_for_risearch_query' do
    it 'does not modify a path with safe characters' do
      expect(
        described_class.escape_path_or_uri_for_risearch_query("/path/to/file.tiff")
      ).to eq(
        "/path/to/file.tiff"
      )
    end

    it 'escapes a single quote in a path that contains single quote' do
      expect(
        described_class.escape_path_or_uri_for_risearch_query("/path/to/someone's-file.tiff")
      ).to eq(
        "/path/to/someone\\'s-file.tiff"
      )
    end

    it 'escapes a colon in a path that contains a colon' do
      expect(
        described_class.escape_path_or_uri_for_risearch_query('s3://bucket_name/path/to/file.tiff')
      ).to eq(
        "s3\\://bucket_name/path/to/file.tiff"
      )
    end
  end
end
