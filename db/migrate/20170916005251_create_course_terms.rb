class CreateCourseTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :course_terms do |t|
      t.references :course
      t.references :term
      t.timestamps
    end

    add_index :course_terms, [:course_id, :term_id], unique: true
  end
end
