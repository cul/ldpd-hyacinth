class DropAuthorizedTerms < ActiveRecord::Migration
  def change
    drop_table :authorized_terms
  end
end
