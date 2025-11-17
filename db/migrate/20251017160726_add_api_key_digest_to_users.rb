class AddApiKeyDigestToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table(:users) do |t|
      t.string :api_key_digest, null: true
    end

    add_index :users, :api_key_digest, unique: true
  end
end
