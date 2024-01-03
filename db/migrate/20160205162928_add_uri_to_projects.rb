class AddUriToProjects < ActiveRecord::Migration[4.2]
  def change
    change_table(:projects) do |t|
      t.text :uri, null: true
    end
  end
end
