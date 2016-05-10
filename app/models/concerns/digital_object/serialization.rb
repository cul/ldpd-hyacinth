module DigitalObject::Serialization
  extend ActiveSupport::Concern

  ######################
  # JSON Serialization #
  ######################

  # JSON representation
  def as_json(_options = {})
    {
      pid: pid,
      created: @db_record.created_at,
      modified: @db_record.updated_at,
      created_by: (@db_record.created_by.present? ? @db_record.created_by.full_name : nil),
      modified_by: (@db_record.updated_by.present? ? @db_record.updated_by.full_name : nil),
      identifiers: identifiers,
      title: get_title(placeholder_if_blank: true),
      state: @fedora_object ? @fedora_object.state : 'A',
      dc_type: dc_type,
      project: project,
      publish_targets: publish_targets.each { |pub| { string_key: pub.string_key, pid: pub.pid } },
      digital_object_type: { string_key: digital_object_type.string_key, display_label: digital_object_type.display_label },
      dynamic_field_data: @dynamic_field_data,
      ordered_child_digital_objects: ordered_child_digital_object_pids.map { |the_pid| { pid: the_pid } },
      parent_digital_objects: parent_digital_object_pids.map { |the_pid| { pid: the_pid } }
    }
  end
end
