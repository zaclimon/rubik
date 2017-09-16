class AddCourseTermIdToAgendaCourses < ActiveRecord::Migration[5.0]
  def change
    add_reference :agenda_courses, :course_term, index: true
  end
end
