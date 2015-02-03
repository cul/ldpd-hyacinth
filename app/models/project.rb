class Project < ActiveRecord::Base

  before_create :create_associated_fedora_object!

  has_many :enabled_dynamic_fields, :dependent => :destroy
  accepts_nested_attributes_for :enabled_dynamic_fields, :allow_destroy => true

  has_many :users, :through => :project_permissions
  has_many :project_permissions, :dependent => :destroy
  accepts_nested_attributes_for :project_permissions, :allow_destroy => true, reject_if: proc { |attributes| attributes['id'].blank? && attributes['user_id'].blank? }

  belongs_to :pid_generator

  validates :display_label, :string_key, presence: true
  validate :validate_custom_asset_directory

  after_save :ensure_that_title_fields_are_enabled_and_required
  before_save :set_defaults_for_blank_fields

  # Returns the associated Fedora Object
  def fedora_object
    return @fedora_obj ||= ActiveFedora::Base.find(self.pid)
  end

  def next_pid
    self.pid_generator.next_pid
  end

  def create_associated_fedora_object!
    pid = self.next_pid
    bag_aggregator = BagAggregator.new(:pid => pid)

    bag_aggregator.datastreams["DC"].dc_identifier = [pid]
    bag_aggregator.datastreams["DC"].dc_type = 'Project'
    bag_aggregator.datastreams["DC"].dc_title = 'Project: ' + self.display_label
    bag_aggregator.label = bag_aggregator.datastreams["DC"].dc_title[0]
    bag_aggregator.save

    self.pid = bag_aggregator.pid
  end

  # Returns enabled dynamic fields (with eager-loaded nested dynamic_field data because we use that frequently)
  def get_enabled_dynamic_fields(digital_object_type)
    return self.enabled_dynamic_fields.includes(:dynamic_field).where(digital_object_type: digital_object_type).to_a
  end

  def get_asset_directory
    if self.full_path_to_custom_asset_directory.present?
      self.full_path_to_custom_asset_directory
    else
      File.join(HYACINTH['default_asset_home'], self.string_key)
    end
  end

  #def validate_presence_of_title_fields
  #
  #  # If ANY dynamic_fields are enabled for a particular DigitalObjectType, ensure that the title fields are also enabled
  #
  #  DigitalObjectType.all.each {|digital_object_type|
  #    enabled_dynamic_fields_for_type = self.enabled_dynamic_fields.select{|enabled_dynamic_field|enabled_dynamic_field.digital_object_type == digital_object_type}
  #
  #    if enabled_dynamic_fields_for_type.length > 0
  #      # If enabled_dynamic_fields_for_type includes any of our ensure_enabled fields, make sure that they're set as *required*
  #      # If not, enable them and set them as required
  #
  #      ensure_enabled = {
  #        'title_non_sort_portion' => {'required' => true},
  #        'title_sort_portion' => {'required' => false}
  #      }
  #      must_be_enabled = ensure_enabled.keys
  #      found_enabled = []
  #
  #      enabled_dynamic_fields_for_type.each {|enabled_df|
  #        if must_be_enabled.include?(enabled_df.dynamic_field.string_key)
  #          found_enabled << enabled_df.dynamic_field.string_key
  #          if ensure_enabled[enabled_df.dynamic_field.string_key]['required'] && ! enabled_df.required
  #            @errors.add(:error, '-> ' + enabled_df.dynamic_field.display_label + ' must be set as a required field for ' + digital_object_type.display_label.pluralize)
  #          end
  #        end
  #      }
  #
  #      (must_be_enabled - found_enabled).each {|string_key|
  #        @errors.add(:error, '-> ' + DynamicField.find_by(string_key: string_key).display_label + ' must be enabled for ' + digital_object_type.display_label.pluralize + ' because at least one other field has been enabled.')
  #      }
  #
  #    end
  #  }
  #
  #end

  def ensure_that_title_fields_are_enabled_and_required

    changes_require_save = false

    # For all DigitalObjectTypes that contain ANY enabled dynamic fields, ensure that the title fields are always enabled (and that title_non_sort_portion is always required)

    DigitalObjectType.all.each {|digital_object_type|
      enabled_dynamic_fields_for_type = self.enabled_dynamic_fields.select{|enabled_dynamic_field|enabled_dynamic_field.digital_object_type == digital_object_type}

      # If enabled_dynamic_fields_for_type includes the title fields, make sure that they're set as *required*
      # If not, enable them and set them as required

      # Check for presence of at least one existing enabled_dynamic_field
      if enabled_dynamic_fields_for_type.length > 0
        ensure_enabled = {
          'title_non_sort_portion' => {'required' => false},
          'title_sort_portion' => {'required' => true}
        }
        must_be_enabled = ensure_enabled.keys
        found_enabled = []

        enabled_dynamic_fields_for_type.each {|enabled_df|
          if must_be_enabled.include?(enabled_df.dynamic_field.string_key)
            found_enabled << enabled_df.dynamic_field.string_key
            if ensure_enabled[enabled_df.dynamic_field.string_key]['required'] && ! enabled_df.required
              enabled_df.required = true
              changes_require_save = true
            end
          end
        }

        (must_be_enabled - found_enabled).each {|string_key|
          self.enabled_dynamic_fields << EnabledDynamicField.new(
            dynamic_field: DynamicField.find_by(string_key: string_key),
            digital_object_type: digital_object_type,
            required: ensure_enabled[string_key]['required']
          )
          changes_require_save = true
        }
      end

    }

    save if changes_require_save

  end

































  # Fedora methods

  #def set_commit_to_fedora_flag
  #  @commit_to_fedora = true
  #end
  #
  #def unset_commit_to_fedora_flag
  #  @commit_to_fedora = false
  #end
  #
  #def commit_to_fedora_if_flag_is_set
  #  if @commit_to_fedora
  #
  #    self.unset_commit_to_fedora_flag # Immediately unset commit_to_fedora_flag so that we don't cause an infinite recursion
  #
  #    # Handle new fedora object creation if necessary
  #    unless is_connected_to_fedora?
  #      namespace_object = Hyacinth::Utils::FedoraUtils.get_or_create_namespace_object(self.pid_generator.namespace)
  #
  #      # Make sure that this object's pid isn't blank
  #      raise 'Tried to create a new Project object in Fedora, but Project\'s pid was blank.' if self.pid.blank?
  #
  #      # Make sure that there isn't already an existing fedora object with this ID
  #      raise 'Tried to create a new Project object in Fedora, but found existing Fedora object with pid equal to this Project\'s pid: ' + self.pid if ActiveFedora::Base.exists?(self.pid)
  #
  #      new_bag_aggregator = BagAggregator.new(:pid => self.pid)
  #      new_bag_aggregator.save
  #
  #      # Save new pid to project
  #      self.fedora_identifier = new_bag_aggregator.pid
  #      self.save
  #
  #      # After the save of this element has worked, make it a member of its namespace object
  #      namespace_object.add_member(new_bag_aggregator)
  #
  #    end
  #
  #    # Commit changes to Fedora
  #
  #    project_bag_aggregator = ActiveFedora::Base.find(self.fedora_identifier, :cast => true) # Doing a fresh search even after new object creation in order to verify that object creation worked
  #    raise 'Error: Could not update associated fedora object BagAggregator because it was not found for Project ' + self.string_key if project_bag_aggregator.nil?
  #
  #    project_bag_aggregator.datastreams["DC"].dc_identifier = self.string_key + '_project'
  #    project_bag_aggregator.datastreams["DC"].dc_title = self.display_label
  #    project_bag_aggregator.datastreams["DC"].dc_type = 'Collection'
  #    project_bag_aggregator.label = self.display_label
  #    project_bag_aggregator.save
  #
  #  end
  #
  #end
  #
  #def destroy_associated_fedora_object_bag_aggregator_if_present
  #  #ActiveFedora::Base.find(self.fedora_identifier, :cast => true).destroy
  #  # TODO: Mark BagAggregator as deleted, but do not actually delete.
  #end
  #
  #def get_required_dynamic_subfields_for_digital_object_type(digital_object_type)
  #  return self.enabled_dynamic_subfields.where(
  #    digital_object_type: digital_object_type, required: true
  #  ).map{|enabled_dynamic_subfield|enabled_dynamic_subfield.dynamic_subfield}
  #end
  #
  #def get_locked_dynamic_subfields_for_digital_object_type(digital_object_type)
  #  return self.enabled_dynamic_subfields.where(
  #    digital_object_type: digital_object_type, locked: true
  #  ).map{|enabled_dynamic_subfield|enabled_dynamic_subfield.dynamic_subfield}
  #end
  #
  #def get_hidden_dynamic_subfields_for_digital_object_type(digital_object_type)
  #  return self.enabled_dynamic_subfields.where(
  #    digital_object_type: digital_object_type, hidden: true
  #  ).map{|enabled_dynamic_subfield|enabled_dynamic_subfield.dynamic_subfield}
  #end

  def enabled_digital_object_types
    return EnabledDynamicField.includes(:digital_object_type).select(:digital_object_type_id).distinct.where(project: self).map{|enabled_dynamic_field|enabled_dynamic_field.digital_object_type}.sort_by{|digital_object_type|digital_object_type.sort_order}
  end

  def as_json(options={})
    return {
      pid: self.pid,
      display_label: self.display_label,
      string_key: self.string_key
    }
  end

  private

  def set_defaults_for_blank_fields

  end

  def validate_custom_asset_directory
    if full_path_to_custom_asset_directory.present?

      puts 'Checking out: ' + self.get_asset_directory

      unless (File.exists?(self.get_asset_directory) &&
          File.readable?(self.get_asset_directory) &&
          File.writable?(self.get_asset_directory)
        )
        errors.add(:full_path_to_custom_asset_directory, 'could not be written to.  Ensure that the path exists and has the correct read/write permissions: "' + full_path_to_custom_asset_directory + '"')
      end
    end

  end

  #def do_before_save_project_cleanup
  #  # Remove any ProjectPermissions with nil users
  #  self.project_permissions.each{|project_permission|
  #    project_permission.destroy if project_permission.user.blank?
  #  }
  #end

  #def ensure_presence_of_system_expected_dynamic_subfields
  #
  #  DigitalObjectType.all.each{|digital_object_type|
  #
  #    system_expected_dynamic_subfields_for_digital_object_type = SystemExpectedDynamicSubfield.where(digital_object_type: digital_object_type)
  #    if system_expected_dynamic_subfields_for_digital_object_type.length > 0
  #      dynamic_subfields_to_system_expected_dynamic_subfields = Hash[system_expected_dynamic_subfields_for_digital_object_type.map{|e| [e.dynamic_subfield, e]}]
  #      dynamic_subfields_that_are_currently_enabled = self.enabled_dynamic_subfields.where(digital_object_type: digital_object_type).map{|e| e.dynamic_subfield}
  #
  #      missing_dynamic_subfields = dynamic_subfields_to_system_expected_dynamic_subfields.keys - dynamic_subfields_that_are_currently_enabled
  #
  #      if missing_dynamic_subfields.length > 0
  #        missing_dynamic_subfields.each {|dynamic_subfield|
  #          # Add missing dynamic_subfield as an enabled_dynamic_subfield
  #          system_expected_dynamic_subfield = dynamic_subfields_to_system_expected_dynamic_subfields[dynamic_subfield]
  #
  #          self.enabled_dynamic_subfields.build(dynamic_subfield: dynamic_subfield, digital_object_type: digital_object_type,
  #            required: system_expected_dynamic_subfield.required,
  #            locked: system_expected_dynamic_subfield.locked,
  #            hidden: system_expected_dynamic_subfield.hidden
  #          )
  #        }
  #      end
  #
  #      # And make sure that all expected_dynamic_subfields have the right attributes (required, locked, hidden)
  #      self.enabled_dynamic_subfields.each {|enabled_dynamic_subfield|
  #        system_expected_dynamic_subfield = dynamic_subfields_to_system_expected_dynamic_subfields[enabled_dynamic_subfield.dynamic_subfield]
  #
  #        unless system_expected_dynamic_subfield.nil?
  #          if system_expected_dynamic_subfield.required
  #            enabled_dynamic_subfield.required = true
  #          end
  #          if system_expected_dynamic_subfield.locked
  #            enabled_dynamic_subfield.locked = true
  #          end
  #          if system_expected_dynamic_subfield.hidden
  #            enabled_dynamic_subfield.hidden = true
  #          end
  #        end
  #
  #      }
  #
  #    end
  #
  #  }
  #
  #end

end
