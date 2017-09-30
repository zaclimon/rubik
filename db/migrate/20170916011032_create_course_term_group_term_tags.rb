class CreateCourseTermGroupTermTags < ActiveRecord::Migration[5.0]
  def change
    create_table :group_term_tags do |t|
      t.references :group
      t.references :term_tag
      t.timestamps
    end
  end
end
