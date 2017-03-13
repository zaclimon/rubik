# frozen_string_literal: true
class Agenda < ApplicationRecord
  include Defaults
  include SerializedRecord::AcceptsNestedAttributeFor

  COURSES_PER_SCHEDULE_RANGE = 1..5

  # belongs_to :academic_degree
  belongs_to :term
  has_many :course_terms,
           ->(agenda) {
             includes(:course)
               .joins(course_term_groups: :course_term_group_term_tags)
               .where(
                 'term_id = ? AND course_term_group_term_tags.term_tag_id IN (?)',
                 agenda.term_id,
                 agenda.agenda_term_tags.pluck(:term_tag_id)
               )
               .group('course_terms.id')
               .having('count(distinct course_term_group_term_tags.term_tag_id) = ?', agenda.agenda_term_tags.count)
               .order('courses.code')
           },
           through: :term
  #          ->(agenda) do
  #            includes(:course_term_group_term_tags)
  #             .where("course_term_group_term_tags.term_tag_id" => agenda.agenda_term_tags.pluck(:term_tag_id))
  #          end,
  #          through: :term
  has_many :agenda_term_tags
  # has_many :academic_degree_course_term_groups, through: :academic_degree
  # has_many :course_term_groups, through: :academic_degree_course_term_groups
  # has_many :course_terms, -> { where(term: term) }, through: :course_term_groups

  # belongs_to :academic_degree_term
  # has_one :academic_degree, through: :academic_degree_term
  # has_one :term, through: :academic_degree_term
  # has_many :academic_degree_term_courses, through: :academic_degree_term
  has_many :courses, autosave: true, dependent: :delete_all, inverse_of: :agenda
  has_many :schedules, dependent: :delete_all

  accepts_nested_attributes_for :courses, allow_destroy: true
  accepts_nested_attributes_for :agenda_term_tags, allow_destroy: true

  serialize :leaves, LeavesSerializer
  serialized_accepts_nested_attributes_for :leaves

  with_options on: [AgendaCreationProcess::STEP_COURSE_SELECTION, AgendaCreationProcess::STEP_GROUP_SELECTION] do
    validates :courses, presence: true
    validates :courses_per_schedule, inclusion: { in: Agenda::COURSES_PER_SCHEDULE_RANGE }
    validates_with Validator
  end

  default :courses_per_schedule, COURSES_PER_SCHEDULE_RANGE.begin
  default :processing, false
  default(:token) { SecureRandom.hex }

  delegate :count, to: :schedules, prefix: true
  delegate :name, to: :academic_degree, prefix: true

  alias_attribute :to_param, :token

  # def course_term_groups
  #   academic_degree_course_term_groups.map(&:course_term_group)
  # end

  def mark_as_finished_processing
    self.processing = false
    self.combined_at = Time.zone.now
  end
end
