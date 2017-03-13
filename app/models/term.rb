# frozen_string_literal: true
class Term < ApplicationRecord
  # has_many :academic_degree_terms,
  #          -> { joins(:academic_degree).order("academic_degrees.name DESC") },
  #          dependent: :delete_all
  # has_many :academic_degrees, through: :academic_degree_terms
  has_many :agendas
  has_many :course_terms
  has_many :course_term_groups, through: :course_terms
  has_many :academic_degree_course_term_groups, through: :course_term_groups
  has_many :academic_degrees, -> { uniq.order(name: :desc) }, through: :academic_degree_course_term_groups
  has_many :term_tags

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }

  scope :enabled, -> { where("enabled_at IS NOT NULL").order(year: :desc, name: :asc) }
end
