# frozen_string_literal: true
class EtsPdf::Etl::CourseTermBuilder < SimpleClosure
  SKIP_COURSES = %w(
    CTN791
    ELE791
    ELE792
    ELE795
    GOL791
    GOL792
    GOL796
    GPA791
    GPA792
    GTI791
    GTI792
    GTS792
    LOG791
    LOG792
    MEC791
    PRE010
  ).freeze

  def initialize(term, tags, parsed_lines)
    @term = term
    @tags = tags
    @parsed_lines = parsed_lines
  end

  def call
    @parsed_lines
      .select(&:parsed?)
      .each_with_object([], &method(:group_by_course_lines))
      .reject(&method(:pruned_courses))
      .each(&method(:build_course_term))
  end

  def group_by_course_lines(parsed_line, memo)
    if !parsed_line.type?(:course)
      memo.last << parsed_line
    elsif different_last_entry?(memo, parsed_line)
      memo << [parsed_line]
    end
  end

  def different_last_entry?(memo, parsed_line)
    memo.last&.fetch(0)&.course&.code != parsed_line.course.code
  end

  def pruned_courses(parsed_lines)
    SKIP_COURSES.include?(parsed_lines[0].course.code)
  end

  def build_course_term(parsed_lines)
    course = Course.where(code: parsed_lines[0].course.code).first_or_create!
    course_term = @term.courses.where(course: course).first_or_create!

    EtsPdf::Etl::GroupBuilder.call(course_term, @tags, parsed_lines[1..-1])
  end
end
