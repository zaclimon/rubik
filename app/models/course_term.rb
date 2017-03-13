# frozen_string_literal: true
class CourseTerm < ApplicationRecord
  include Defaults

  belongs_to :course
  belongs_to :term
  has_many :course_term_groups
  has_many :course_term_periods

  serialize :period_pivots, JSON

  validates :course, presence: true, uniqueness: { scope: :term }
  validates :term, presence: true
  validates :period_pivots, presence: true
  validate :period_grouping_strategy_valid?

  default :period_pivots, [:group]

  delegate :grouped_periods, to: :period_grouping_strategy
  delegate :valid?, to: :period_grouping_strategy, prefix: true

  private

  def period_grouping_strategy
    @period_grouping_strategy ||= PeriodGroupingStrategy.new(
      course_term: self,
      pivots: period_pivots,
    )
  end
end
