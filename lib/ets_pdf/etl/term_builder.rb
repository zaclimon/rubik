# frozen_string_literal: true
class EtsPdf::Etl::TermBuilder < SimpleClosure
  TERM_HANDLES = {
    "automne" => "Automne",
    "ete" => "Été",
    "hiver" => "Hiver",
  }.freeze

  def initialize(units)
    @units = units
  end

  def call
    @units
      .map(&method(:normalize_name))
      .group_by(&method(:group_terms))
      .each(&method(:create_term))
  end

  private

  def normalize_name(unit)
    name = TERM_HANDLES[unit[:term]] || raise("Invalid term handle '#{unit[:term]}'")
    unit.except(:term).merge(name: name)
  end

  def group_terms(unit)
    unit.slice(:name, :year)
  end

  def create_term(attributes, units)
    term = Term.where(attributes).first_or_create!

    Pipe
      .bind(->(term_units) { EtsPdf::Etl::AcademicDegreeTermTagBuilder.call(term, term_units) })
      .bind(->(term_units) { EtsPdf::Etl::GroupTermTagBuilder.call(term, term_units) })
      .bind(->(term_units) { create_course_terms(term, term_units) })
      .call(units.map { |unit| unit.except(*attributes.keys) })
  end

  def create_course_terms(term, units)
    units.each { |unit| EtsPdf::Etl::CourseTermBuilder.call(term, unit[:tags], unit[:parsed_lines]) }
  end
end
