# frozen_string_literal: true
class EtsPdf::Etl::Transform::AcademicDegreeUpdater
  SKIP_COURSES = %w(PRE010).freeze

  def initialize(academic_degree_term, lines)
    @academic_degree_term = academic_degree_term
    @lines = lines
  end

  def execute
    course_term = nil
    # course_term_group = nil

    @lines.each do |line|
      if line.type?(:course)
        if course_term.course.code == line.course.code
          # Continue on
        else
          course = Course.where(code: line.course.code).first_or_create!
          course_term = CourseTerm.where(course: course, term: @academic_degree_term.term).first_or_create!
        end

      elsif line.type?(:group)

      elsif line.type?(:period)

      end
    end

    # WIP
    # course_term = nil
    # course_term_group = nil
    #
    # @lines.each do |line|
    #   if line.type?(:course)
    #     course_term.save! if course_term.present?
    #
    #     course = Course.where(code: line.course.code).first_or_create!
    #     course_term = CourseTerm.where(course: course, term: @academic_degree_term.term).first_or_create!
    #     course_term_group = nil
    #   elsif line.type?(:group)
    #     number = Integer(line.group.number.sub(/^0+/, ""))
    #     course_term_group = course_term.course_term_groups.where(number: number).first_or_initialize
    #
    #     EtsPdf::Etl::Transform::PeriodUpdater.new(course_term_group, line.group).execute
    #   elsif line.type?(:period)
    #     raise "FUUUUUU" if course_term_group.nil?
    #
    #     EtsPdf::Etl::Transform::PeriodUpdater.new(course_term_group, line.period).execute
    #   end
    # end
    # course_term.save!
    # Probably better to iterate and save! once
    # Then reconciliate
    # END WIP

    # @academic_degree_term_course = AcademicDegreeTermCourse.new
    # @group = nil
    # @lines.each do |parsed_line|
    #   update(parsed_line) if parsed_line.parsed?
    # end
    # save_course!
  end

  private

  def compare(course_term, a, b)
    raise [
        @academic_degree_term.term.year,
        @academic_degree_term.term.name,
        @academic_degree_term.term.tags,
        @academic_degree_term.academic_degree.code,
        course_term.course.code,
        a.number,
        a.periods.to_json,
        "---",
        b.number,
        b.periods.to_json,
    ].join(",") if b.present? && a.present? && a.number == b.number && a.periods != b.periods
  end

  def update(parsed_line)
    return update_course(parsed_line.course) if parsed_line.type?(:course)
    return update_group(parsed_line.group) if parsed_line.type?(:group)
    update_period(parsed_line.period) if parsed_line.type?(:period)
  end

  def update_course(course_data)
    save_course!
    @academic_degree_term_course =
      EtsPdf::Etl::Transform::AcademicDegreeTermCourseUpdater.new(@academic_degree_term, course_data).execute
    @group = nil
  end

  def update_group(group_data)
    @group = EtsPdf::Etl::Transform::GroupUpdater.new(@academic_degree_term_course, group_data).execute
  end

  def update_period(period_data)
    raise ParsingError, @academic_degree_term_course if @group.nil?

    EtsPdf::Etl::Transform::PeriodUpdater.new(@group, period_data).execute
  end

  def save_course!
    @academic_degree_term_course.save! unless skip_save?
  end

  def skip_save?
    return true if @academic_degree_term_course.groups.empty?
    SKIP_COURSES.include?(@academic_degree_term_course.course.code)
  end

  class ParsingError < StandardError
    def initialize(academic_degree_term_course)
      super format(academic_degree_term_course)
    end

    private

    def format(academic_degree_term_course)
      term = academic_degree_term_course.academic_degree_term.term

      stacktrace = [
        term.year,
        term.name,
        term.tags,
        academic_degree_term_course.academic_degree_term.academic_degree.code,
        academic_degree_term_course.course.code,
      ].join(", ")
      "Parsing error for #{stacktrace}"
    end
  end
end
