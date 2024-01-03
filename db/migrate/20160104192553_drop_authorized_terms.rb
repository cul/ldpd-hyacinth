class DropAuthorizedTerms < ActiveRecord::Migration[4.2]
  def change
    drop_table :authorized_terms
  end
end
