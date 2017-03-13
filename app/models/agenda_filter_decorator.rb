# frozen_string_literal: true
class AgendaFilterDecorator
  include ActiveModel::AttributeAssignment

  class Filter
    include ActiveModel::Model

    attr_accessor :params

    def applied?
      value.present?
    end

    def name
      self.class.name.underscore.gsub(/agenda_filter_decorator\/(.*)_filter$/, '\1')
    end

    def to_partial_path
      "agenda_filter_decorator/filter/#{name}"
    end

    def value
      params[key]
    end
  end

  class AcademicDegreeFilter < Filter
    def key
      :academic_degree_id
    end

    def object
      @object ||= AcademicDegree.find_by(id: value)
    end
  end

  FILTERS = [AcademicDegreeFilter]

  attr_accessor :object, :params

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def course_terms
    @course_terms ||= begin
      if filters[:academic_degree].blank?
        object.course_terms
      else
        object.course_terms.where(
          course_term_groups: {
            academic_degree_course_term_groups: { academic_degree_id: filters[:academic_degree].value }
          }
        )
      end
    end
  end

  def filters
    @filters ||=
      FILTERS
        .map { |filter_class| filter_class.new(params: params) }
        .select(&:applied?)
        .map { |filter| [filter.name, filter] }
        .to_h
        .with_indifferent_access
  end

  def method_missing(method_name, *args, &block)
    respond_to_missing?(method_name) ? object.send(method_name, *args, &block) : super
  end

  def respond_to_missing?(method_name, *_arguments, &_block)
    object.respond_to?(method_name)
  end
end
