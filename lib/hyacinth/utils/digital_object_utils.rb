module Hyacinth::Utils::DigitalObjectUtils
  def self.in_batches(start_at, size=500, title="Process")
    # Go through all known DigitalObjectRecords in the DB and yield them.
    # Do this in batches so that we don't return data for millions of records, all at once.

    total = DigitalObjectRecord.count
    puts "Processing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
    progressbar = ProgressBar.create(:title => title, :starting_at => start_at, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

    DigitalObjectRecord.find_each(batch_size: size, start: start_at) do |digital_object_record|
      yield digital_object_record if block_given?
      progressbar.increment
    end

    Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
    progressbar.finish

    puts "Done!"
  end
  def self.in_list(file_path, key)
    total = File.foreach(file_path).count
    puts "Processing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
    progressbar = ProgressBar.create(:title => title, :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')
    File.foreach(file_path) do |value|
      buffer << value
      if buffer.size > 19
        DigitalObjectRecord.where(key.to_sym => buffer).each do |digital_object_record|
          yield digital_object_record if block_given?
          progressbar.increment
        end
        buffer.slice!(0,buffer.size)
      end
    end
    if buffer.size > 0
      DigitalObjectRecord.where(key.to_sym => buffer).each do |digital_object_record|
        yield digital_object_record if block_given?
        progressbar.increment
      end
    end
    Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
    progressbar.finish

    puts "Done!"
  end
end
