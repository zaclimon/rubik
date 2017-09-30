# frozen_string_literal: true
class EtsPdf::Etl::TermTagBuilder < SimpleClosure
  def initialize(term, units, scope, labels, ignorable_labels = [])
    @term = term
    @units = units
    @scope = scope
    @labels = labels
    @ignorable_labels = ignorable_labels
  end

  def call
    @units
      .map(&method(:add_tags_attribute))
      .map(&method(:normalize_term_tag))
      .map(&method(:consolidate_term_tag_attributes))
      .group_by(&method(:group_term_tags))
      .each_with_object([], &method(:create_term_tag))
  end

  private

  def add_tags_attribute(unit)
    unit.merge(tags: unit.fetch(:tags, []))
  end

  def normalize_term_tag(unit)
    denormalized_value = unit[@scope]
    normalized_value = @labels[denormalized_value]
    raise("Invalid #{@scope} term tag '#{denormalized_value}'") if invalid_label?(denormalized_value, normalized_value)

    unit.merge(@scope => normalized_value)
  end

  def invalid_label?(denormalized_value, normalized_value)
    !@ignorable_labels.include?(denormalized_value) && normalized_value.blank?
  end

  def consolidate_term_tag_attributes(unit)
    attributes = { label: unit[@scope], scope: @scope }
    unit.merge(@scope => attributes)
  end

  def group_term_tags(unit)
    unit[@scope]
  end

  def create_term_tag((attributes, units), memo)
    tag = attributes[:label].present? ? @term.tags.create!(attributes) : nil

    memo.concat(
      units.map { |unit| unit.merge(tags: Array(unit[:tags]) + Array(tag)).except(@scope) }
    )
  end
end
