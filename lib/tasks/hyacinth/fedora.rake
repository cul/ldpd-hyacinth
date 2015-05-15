namespace :hyacinth do

  namespace :fedora do

    # Loads/reloads all required Fedora content models
    # Note: Don't include Rails environment for this task, since enviroment includes a check for the presence of CModels in Fedora
    task :reload_cmodels do
      print_out_solr_and_fedora_urls
      Rake::Task["cul_hydra:cmodel:reload_all"].invoke
    end

  end

end
