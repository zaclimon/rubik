class CreateFilters < ActiveRecord::Migration[5.0]
  def change
    remove_column :terms, :tags

    create_table :term_tags do |t|
      t.references :term
      t.string :label
      t.string :scope
      t.timestamps
    end

    create_table :course_term_group_term_tags do |t|
      t.references :course_term_group
      t.references :term_tag
      t.timestamps
    end

    create_table :agenda_term_tags do |t|
      t.references :agenda
      t.references :term_tag
      t.timestamps
    end
  end
end
