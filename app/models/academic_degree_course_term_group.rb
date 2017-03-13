# frozen_string_literal: true
class AcademicDegreeCourseTermGroup < ApplicationRecord
  belongs_to :academic_degree
  belongs_to :course_term_group
end
