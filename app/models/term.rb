# frozen_string_literal: true
class Term < ApplicationRecord
  has_many :courses, class_name: 'CourseTerm', inverse_of: :term
  has_many :tags, class_name: 'TermTag', inverse_of: :term

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }

  scope :enabled, -> { where("enabled_at IS NOT NULL").order(year: :desc, name: :asc) }
end
