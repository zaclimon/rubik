# frozen_string_literal: true
class PeriodGroupingStrategy
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :course_term
  attr_reader :pivots

  validates :course_term, presence: true
  validates :pivots, presence: true # validate presence in CourseTermPeriod model attributes

  delegate :course_term_periods, to: :course_term

  def grouped_periods
    @grouped_periods ||= build_pivots(course_term_periods.to_a, pivots)
  end

  def pivots=(value)
    @pivots = value.map(&:to_sym)
  end

  private

  def build_pivots(grouped_periods, pivots)
    current_pivots = pivots.dup
    current_pivot = current_pivots.shift

    periods =
      if current_pivots.empty?
        grouped_periods
      else
        grouped_periods.group_by(&current_pivot).map { |_, periods| build_pivots(periods, current_pivots) }
      end

    Pivot.new(periods: periods, pivot: current_pivot)
  end

  class Pivot
    include ActiveModel::Model

    attr_accessor :periods, :pivot
  end
end
