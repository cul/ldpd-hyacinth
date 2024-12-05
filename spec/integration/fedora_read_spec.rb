require 'rails_helper'

describe "Fedora content ds read tests" do
  describe "creating an Asset and attempting to download the bytes directly from Fedora" do
    let(:pid) { 'sample:123' }
    let(:docker_mounted_fixture_file_location) { '/opt/fixtures/files/lincoln.jpg' }

    it "works" do
      generic_resource = GenericResource.new(pid: pid)
      content_ds = generic_resource.create_datastream(
        ActiveFedora::Datastream,
        'content',
        controlGroup: 'E',
        mimeType: BestType.mime_type.for_file_name(docker_mounted_fixture_file_location),
        dsLabel: File.basename(docker_mounted_fixture_file_location),
        versionable: true
      )
      content_ds.dsLocation = "file://#{docker_mounted_fixture_file_location}"
      generic_resource.add_datastream(content_ds)

      generic_resource.save

      expect(generic_resource.datastreams['content'].dsLocation).to eq("file://#{docker_mounted_fixture_file_location}")
      expect(generic_resource.datastreams['content'].content.length).to be_positive
    end

    # Uncomment this "test" when debugging Fedora errors:
    # it "reads the fedora log to find out what went wrong", focus: true do
    #   puts 'reading fedora log now...'
    #   sleep 20
    #   puts `docker container list`
    #   fedora_container_id = `docker container list | grep fedora | awk '{print $1}'`.strip
    #   puts "fedora_container_id: #{fedora_container_id}"
    #   puts `docker exec #{fedora_container_id} ls -la /opt/fedora/server/logs/fedora.log`
    #   fedora_log_content = `docker exec #{fedora_container_id} cat /opt/fedora/server/logs/fedora.log`
    #   puts "fedora_log_content: #{fedora_log_content}"
    #   expect(fedora_log_content).to eq('')
    # end
  end
end
