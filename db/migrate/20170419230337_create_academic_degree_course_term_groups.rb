class CreateAcademicDegreeCourseTermGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :academic_degree_course_term_groups do |t|
      t.references :academic_degree
      t.references :course_term_group
      t.timestamps
    end

    add_index :academic_degree_course_term_groups,
              [:academic_degree_id, :course_term_group_id],
              unique: true,
              name: "academic_degree_course_term_groups_index"
  end
end
