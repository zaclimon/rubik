class RemoveTagsFromTerms < ActiveRecord::Migration[5.0]
  def change
    remove_column :terms, :tags
  end
end
