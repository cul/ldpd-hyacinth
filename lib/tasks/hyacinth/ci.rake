require "active-fedora"
require 'jettywrapper'

namespace :hyacinth do

  begin
    # This code is in a begin/rescue block so that the Rakefile is usable
    # in an environment where RSpec is unavailable (i.e. production).

    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:rspec) do |spec|
      spec.pattern = FileList['spec/**/*_spec.rb']
      spec.pattern += FileList['spec/*_spec.rb']
      spec.rspec_opts = ['--backtrace'] if ENV['CI']
    end

    RSpec::Core::RakeTask.new(:rcov) do |spec|
      spec.pattern = FileList['spec/**/*_spec.rb']
      spec.pattern += FileList['spec/*_spec.rb']
      spec.rcov = true
    end
  rescue LoadError => e
    puts "[Warning] Exception creating rspec rake tasks.  This message can be ignored in environments that intentionally do not pull in the RSpec gem (i.e. production)."
    puts e
  end

  desc "CI build"
  task :ci do
    
    Rails.env = 'test'
    Jettywrapper.url = "https://github.com/elo2112/hydra-jetty/archive/hyacinth-fedora-3.7-with-risearch.zip"
    Jettywrapper.jetty_dir = File.join(Rails.root, 'jetty-test')
    Jettywrapper.jetty_dir = File.join(Rails.root, 'jetty-test')

    unless File.exists?(Jettywrapper.jetty_dir)
      puts "\n"
      puts 'No test jetty found.  Will download / unzip a copy now.'
      puts "\n"
    end
    
    Rake::Task["jetty:clean"].invoke
    
    jetty_params = Jettywrapper.load_config.merge({jetty_home: Jettywrapper.jetty_dir})
    error = Jettywrapper.wrap(jetty_params) do
      Rake::Task["hyacinth:fedora:reload_cmodels"].invoke
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:seed"].invoke
      ENV['CLEAR'] = 'true' # Set ENV variable for reindex task
      Rake::Task['hyacinth:index:reindex'].invoke
      ENV['CLEAR'] = nil  # Clear ENV variable because we're done with it
      Rake::Task['hyacinth:projects:test:setup'].invoke
      Rake::Task['hyacinth:coverage'].invoke
    end
    raise "test failures: #{error}" if error
  end

  desc "Execute specs with coverage"
  task :coverage do
    # Put spec opts in a file named .rspec in root
    ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
    ENV['COVERAGE'] = 'true' unless ruby_engine == 'jruby'

    Rake::Task["hyacinth:rspec"].invoke
  end

end
