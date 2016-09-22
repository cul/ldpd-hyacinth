class AddShortLabelToProjects < ActiveRecord::Migration
  def change
    change_table(:projects) do |t|
      t.string :short_label, null: true, limit: 255
    end
  end
end
