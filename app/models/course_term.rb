# frozen_string_literal: true
class CourseTerm < ApplicationRecord
  belongs_to :course
  belongs_to :term, inverse_of: :courses
  has_many :groups

  validates :course, presence: true, uniqueness: { scope: :term }
  validates :term, presence: true
end
