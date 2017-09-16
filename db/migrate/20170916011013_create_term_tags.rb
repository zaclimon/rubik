class CreateTermTags < ActiveRecord::Migration[5.0]
  def change
    create_table :term_tags do |t|
      t.references :term
      t.string :label
      t.string :scope
      t.timestamps
    end

    add_index :term_tags, [:term_id, :label, :scope], unique: true
  end
end
