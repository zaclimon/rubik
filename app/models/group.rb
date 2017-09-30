# frozen_string_literal: true
class Group < ApplicationRecord
  include Defaults
  include SerializedRecord::FindOrInitializeFor

  has_many :term_tags, class_name: 'GroupTermTag', inverse_of: :group

  validates :periods, presence: true

  serialize :periods, PeriodsSerializer
  serialized_find_or_initialize_for :periods

  default :periods, []

  delegate :empty?, to: :periods

  def overlaps?(other)
    periods.any? do |period|
      other.periods.any? { |other_period| period.overlaps?(other_period) }
    end
  end
end
