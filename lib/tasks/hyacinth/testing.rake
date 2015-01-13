namespace :hyacinth do

  namespace :testing do

    task :create_sample_digital_objects => :environment do

      test_project = Project.find_by(string_key: 'test')
      test_user = User.find_by(email: 'hyacinth-test@library.columbia.edu')

      number_of_records_to_create = 400
      counter = 0

      start_time = Time.now

      number_of_records_to_create.times {

        digital_object = DigitalObject::Item.new
        digital_object.projects << test_project
        digital_object.created_by = test_user
        digital_object.updated_by = test_user

        random_adj = RandomWord.adjs.next
        random_adj.capitalize if random_adj
        random_noun = RandomWord.nouns.next
        random_noun.capitalize if random_noun
        random_title = random_adj.to_s + ' ' + random_noun.to_s

        digital_object.update_dynamic_field_data(
          {
            'title' => [
              {
                'title_sort_portion' => random_title
              }
            ],
            'name' => [
              {
                'name_value' => Faker::Name.name
              },
              {
                'name_value' => Faker::Name.name
              }
            ],
            'note' => [
              {
                'note_value' => Faker::Lorem.paragraph
              }
            ]
          }
        )

        unless digital_object.save
          puts 'Errors: ' + digital_object.errors.inspect
        end

        counter += 1
        puts "Processed #{counter} of #{number_of_records_to_create}"

      }

      puts 'Done.  Took ' + (Time.now - start_time).to_s + ' seconds.'

    end

  end

end
