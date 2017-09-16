class CreateCourseTermGroupTermTags < ActiveRecord::Migration[5.0]
  def change
    create_table :course_term_group_term_tags do |t|
      t.references :course_term_group
      t.references :term_tag
      t.timestamps
    end
  end
end
