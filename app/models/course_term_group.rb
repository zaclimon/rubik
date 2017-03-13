# frozen_string_literal: true
class CourseTermGroup < ApplicationRecord
  include SerializedRecord::FindOrInitializeFor

  belongs_to :course_term
  has_many :academic_degree_course_term_groups
  has_many :course_term_group_term_tags

  validates :number, presence: true, uniqueness: { scope: :course_term }
  validates :periods, presence: true

  serialize :periods, PeriodsSerializer
  serialized_find_or_initialize_for :periods
end
