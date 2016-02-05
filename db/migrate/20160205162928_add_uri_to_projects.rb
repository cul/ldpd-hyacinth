class AddUriToProjects < ActiveRecord::Migration
  def change
    change_table(:projects) do |t|
      t.text :uri, null: true
    end
  end
end
