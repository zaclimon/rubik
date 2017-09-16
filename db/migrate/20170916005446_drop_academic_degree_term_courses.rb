class DropAcademicDegreeTermCourses < ActiveRecord::Migration[5.0]
  def change
    drop_table :academic_degree_term_courses
  end
end
