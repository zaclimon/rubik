# frozen_string_literal: true
class EtsPdf::Etl::GroupBuilder < SimpleClosure
  def initialize(course_term, tags, parsed_lines)
    @course_term = course_term
    @tags = tags
    @parsed_lines = parsed_lines
  end

  def call
    @parsed_lines
      .each_with_object([], &method(:group_by_group_lines))
      .each(&method(:build_period))
  end

  private

  def group_by_group_lines(parsed_line, memo)
    if parsed_line.type?(:group) && different_last_entry?(memo, parsed_line)
      memo << [parsed_line]
    else
      memo.last << parsed_line
    end
  end

  def different_last_entry?(memo, parsed_line)
    memo.last&.fetch(0)&.group&.number != parsed_line.group.number
  end

  def build_period(parsed_lines)
    group_line = parsed_lines[0]
    group_number = Integer(group_line.group.number.sub(/^0+/, ""))

    group = @course_term.groups.where(number: group_number).first_or_initialize
    periods = EtsPdf::Etl::PeriodBuilder.call(parsed_lines)

    if group.new_record?
      group.periods = periods
      group.save!
    else
      raise "Periods mismatch" if group.periods != periods
    end

    @tags.each { |tag| group.term_tags.where(term_tag: tag).first_or_create! }
  end
end
