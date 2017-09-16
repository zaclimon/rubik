class RemoveAcademicDegreeTermCourseId < ActiveRecord::Migration[5.0]
  def change
    remove_column :agenda_courses, :academic_degree_term_course_id, :integer
  end
end
