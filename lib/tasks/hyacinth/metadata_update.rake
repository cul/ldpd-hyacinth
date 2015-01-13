require "active-fedora"

MODS_NS = {'mods'=>'http://www.loc.gov/mods/v3'}

namespace :hyacinth do

  namespace :metadata_update do

    task :update_item_in_context => :environment do

      mode = 'lindquist'

      puts 'Updade mode: ' + mode

      lindquist_url_base = 'http://lindquist.cul.columbia.edu/catalog/'
      css_url_base = 'http://css.cul.columbia.edu/catalog/'

      lindquist_pid = 'ldpd:130509'
      css_pid = 'ldpd:135833'

      if mode == 'lindquist'
        url_base = lindquist_url_base
        top_level_pid = lindquist_pid
      elsif mode == 'css'
        url_base = css_url_base
        top_level_pid = css_pid
      else
        puts 'Invalid mode'
        next
      end

      members = Cul::Scv::Hydra::RisearchMembers.get_recursive_member_pids(top_level_pid, true, 'ContentAggregator')

      counter = 0
      members.each do |pid|

        obj = ActiveFedora::Base.find(pid)

        old_content = obj.datastreams['descMetadata'].content
        ng_content = Nokogiri::XML(old_content){|config| config.default_xml.noblanks}

        item_identifier = ng_content.xpath("/mods:mods/mods:identifier[@type='local']", MODS_NS).first.text

        if mode == 'css'
          item_identifier = item_identifier.gsub('.', '_')
        end

        possibly_present_object_in_context_url = ng_content.xpath("/mods:mods/mods:location/mods:url[@access='object in context' and @usage='primary display']", {'mods'=>'http://www.loc.gov/mods/v3'})

        if item_identifier.blank?
          puts 'Notice: Skipping ' + pid + ' because it does not appear to have an identifier.'
          next
        end

        if possibly_present_object_in_context_url.present?
          puts 'Notice: Skipping update for ' + pid + '. Found existing object in context url: ' + possibly_present_object_in_context_url.first.text
        else
          new_object_in_context_url = url_base + item_identifier
          puts 'Adding object in context url: ' + new_object_in_context_url

          location_element = ng_content.xpath('/mods:mods/mods:location', MODS_NS).first
          if location_element.blank?
            puts 'Notice: Could not find location element for ' + pid + '.  Skipping.'
            next
          end
          object_in_context_node = Nokogiri::XML::Node.new "url", ng_content
          object_in_context_node.content = new_object_in_context_url
          object_in_context_node.set_attribute('access', 'object in context')
          object_in_context_node.set_attribute('usage', 'primary display')
          location_element.add_child(object_in_context_node)

          obj.datastreams['descMetadata'].content = ng_content.to_xml(:indent => 2)
          obj.save

        end

        counter += 1

        puts 'Updated ' + counter.to_s + ' of ' + members.length.to_s
      end

      puts members.length.to_s + ' members updated'

    end

  end

end
