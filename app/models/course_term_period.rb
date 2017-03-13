# frozen_string_literal: true
class CourseTermPeriod < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :course_term

  def ==(other)
    course_term_id == other.course_term_id &&
      group == other.group &&
      type == other.type &&
      frequency == other.frequency &&
      phase == other.phase &&
      starts_at == other.starts_at &&
      ends_at == other.ends_at
  end
end
