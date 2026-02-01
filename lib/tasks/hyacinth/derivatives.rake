namespace :hyacinth do
  namespace :derivatives do
    desc "Queues derivative generation for the given PIDs, skipping objects that have already had their derivatives generated"
    task :queue_derivative_generation_if_necessary => :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      elsif ENV['PIDLIST'].present?
        pids = open(ENV['PIDLIST'],'r').map(&:strip)
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      total = pids.length
      puts "Generating derivatives (if missing) for #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Queueing", :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      pids.each do |pid|
        begin
          DigitalObject::Base.find(pid).run_derivative_updates_if_necessary
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
        progressbar.increment
      end

      progressbar.finish

      puts "Done!"
    end
  end
end
