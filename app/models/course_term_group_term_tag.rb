# frozen_string_literal: true
class CourseTermGroupTermTag < ApplicationRecord
  belongs_to :course_term_group
  belongs_to :term_tag
end
