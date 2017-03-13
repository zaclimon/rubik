# frozen_string_literal: true
class EtsPdf::Etl::Transform::BachelorUpdater
  SKIP_COURSES = %w(PRE010).freeze
  BACHELOR_HANDLES = {
    "seg" => "Enseignements généraux",
    "ctn" => "Génie de la construction",
    "ele" => "Génie électrique",
    "log" => "Génie logiciel",
    "mec" => "Génie mécanique",
    "gol" => "Génie des opérations et de la logistique",
    "gpa" => "Génie de la production automatisée",
    "gti" => "Génie des technologies de l'information",
  }.freeze

  def initialize(term, term_tag, data)
    @term = term
    @term_tag = term_tag
    @data = data
  end

  def execute
    @data.each do |bachelor_handle, lines|
      bachelor_name = BACHELOR_HANDLES[bachelor_handle] || raise("Invalid bachelor handle \"#{bachelor_handle}\"")
      tag = @term.term_tags.where(label: bachelor_name, scope: :academic_degree).first_or_create!
      # academic_degree = AcademicDegree.where(code: bachelor_handle).first_or_create!(name: bachelor_name)

      # WIP
      # course_term = nil
      # course_term_group = nil
      #
      # lines.each do |line|
      #   if line.type?(:course)
      #     if course_term.nil? || course_term.course.code != line.course.code
      #       if course_term.present?
      #         reconcile(tag, course_term_group)
      #         course_term.save!
      #       end
      #
      #       course = Course.where(code: line.course.code).first_or_create!
      #       course_term = CourseTerm.where(course: course, term: @term).first_or_initialize
      #       course_term_group = nil
      #     end
      #   elsif line.type?(:group)
      #     number = Integer(line.group.number.sub(/^0+/, ""))
      #
      #     if course_term_group.nil? || course_term_group.number != number
      #       reconcile(tag, course_term_group)
      #       course_term_group = CourseTermGroup.new(course_term: course_term, number: number)
      #     end
      #
      #     EtsPdf::Etl::Transform::PeriodUpdater.new(course_term_group, line.group).execute
      #   elsif line.type?(:period)
      #     raise "FUUUUUU" if course_term_group.nil?
      #
      #     EtsPdf::Etl::Transform::PeriodUpdater.new(course_term_group, line.period).execute
      #   end
      # end
      # reconcile(tag, course_term_group)
      # course_term.save!

      course_term = nil
      periods = PeriodCollection.new

      lines.each do |line|
        if line.type?(:course)
          if course_term.nil? || course_term.course.code != line.course.code
            if course_term.present?
              reconcile(course_term, periods)
              course_term.save!
            end

            course = Course.where(code: line.course.code).first_or_create!
            course_term = CourseTerm.where(course: course, term: @term).first_or_initialize
            periods = PeriodCollection.new
          end
        elsif line.type?(:group)
          number = Integer(line.group.number.sub(/^0+/, ""))

          if periods.empty? || periods.group != number
            reconcile(course_term, periods)
            periods = PeriodCollection.new
          end

          period = PeriodUpdater.new(course_term: course_term, period_data: line.group).call
          period.group = number
          periods << period
        elsif line.type?(:period)
          period = PeriodUpdater.new(course_term: course_term, period_data: line.period).call
          raise "FUUU1" if periods.empty?
          period.group = periods.group
          periods << period
        end
      end
      reconcile(course_term, periods)
      course_term.save!

      # academic_degree_term = @term.academic_degree_terms.where(academic_degree: academic_degree).first_or_create!
      # EtsPdf::Etl::Transform::AcademicDegreeUpdater.new(academic_degree_term, lines).execute
    end
  end

  private

  # def reconcile(tag, course_term_group)
  #   return if course_term_group.nil?
  #   existing_course_term_group = course_term_group.course_term.course_term_groups.find_by(number: course_term_group.number)
  #
  #   if existing_course_term_group.present?
  #     if !course_term_group.course_term.course.code.in?(SKIP_COURSES) && existing_course_term_group.periods == course_term_group.periods
  #       @term_tag.course_term_group_term_tags.create!(course_term_group: existing_course_term_group) unless @term_tag.nil?
  #       tag.course_term_group_term_tags.create!(course_term_group: existing_course_term_group)
  #       # Tagging.create!(tag_id: tag.id, course_term_group_id: existing_course_term_group.id)
  #       # academic_degree.academic_degree_course_term_groups.create!(course_term_group: existing_course_term_group)
  #     else
  #       raise [
  #         @term.year,
  #         @term.name,
  #         @term.tags,
  #         # academic_degree.code,
  #         course_term_group.course_term.course.code,
  #         "---",
  #         course_term_group.number,
  #         course_term_group.periods.to_json,
  #         "---",
  #         existing_course_term_group.number,
  #         existing_course_term_group.periods.to_json,
  #       ].join("\n")
  #     end
  #   elsif !course_term_group.course_term.course.code.in?(SKIP_COURSES)
  #     course_term_group.save!
  #     @term_tag.course_term_group_term_tags.create!(course_term_group: course_term_group) unless @term_tag.nil?
  #     tag.course_term_group_term_tags.create!(course_term_group: course_term_group)
  #     # Tagging.create!(tag_id: tag.id, course_term_group_id: course_term_group.id)
  #     # academic_degree.academic_degree_course_term_groups.create!(course_term_group: course_term_group)
  #   end
  # end

  def reconcile(course_term, periods)
    return if periods.empty?
    return if course_term.course.code.in?(SKIP_COURSES)
    existing_periods = course_term.course_term_periods.where(group: periods.group)

    if existing_periods.empty? &&
      periods.save!
    elsif periods != existing_periods
      raise [
        @term.year,
        @term.name,
        course_term.course.code,
        "---",
        periods.to_json,
        "---",
        existing_periods.to_json,
      ].join("\n")
    end
  end

  class PeriodUpdater
    include ActiveModel::Model

    MINUTES_IN_DAY = 24 * 60
    TYPES = {
      "Atelier" => "Atelier",
      "C" => "C",
      "Labo" => "Labo",
      "Labo/2" => "Labo/2",
      "Labo A" => "Labo",
      "Labo A+B" => "Labo A+B",
      "Labo B" => "Labo",
      "Labo C" => "Labo",
      "Projet" => "Projet",
      "Projets" => "Projets",
      "TP" => "TP",
      "TP/2" => "TP/2",
      "TP A" => "TP",
      "TP A + B" => "TP A+B",
      "TP A+B" => "TP A+B",
      "TP B" => "TP",
      "TP/Labo" => "TP/Labo",
      "TP-Labo A" => "TP-Labo",
      "TP-Labo B" => "TP-Labo",
      "TP-Labo/2" => "TP-Labo/2",
    }.freeze

    attr_accessor :course_term, :period_data

    def call
      CourseTermPeriod.new(course_term: course_term, type: type, starts_at: starts_at, ends_at: ends_at)
    end

    private

    def type
      TYPES[period_data.type] || raise(ArgumentError, "Type #{period_data.type} is not allowed")
    end

    def starts_at
      int_value_of(period_data.start_time)
    end

    def ends_at
      int_value_of(period_data.end_time)
    end

    def int_value_of(time)
      hours, minutes = time.split(":").map(&:to_i)
      weekday_index * MINUTES_IN_DAY + hours * 60 + minutes
    end

    def weekday_index
      I18n.t("date.abbr_day_names").index { |abbr| abbr.casecmp(period_data.weekday.downcase).zero? }
    end
  end

  class PeriodCollection
    delegate :==, :empty?, :to_json, to: :@periods
    delegate :group, to: :'@periods.first'

    def initialize
      @periods = []
    end

    def <<(value)
      raise "FUUU9000" if @periods.any? { |period| period.group != value.group }
      @periods << value
    end

    def save!
      @periods.each(&:save!)
    end
  end
end
