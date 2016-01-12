class RemoveXmlDatastreamFromDynamicFieldGroups < ActiveRecord::Migration
  def change
    change_table :dynamic_field_groups do |t|
      t.remove_references :xml_datastream
    end
  end
end
