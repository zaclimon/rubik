class AddCourseTermIdToAgendaCourses < ActiveRecord::Migration[5.0]
  def change
    add_reference :agenda_courses, :course_term, after: :agenda_id, index: true
  end
end
