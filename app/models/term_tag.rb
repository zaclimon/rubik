# frozen_string_literal: true
class TermTag < ApplicationRecord
  belongs_to :term, inverse_of: :tags

  validates :term, presence: true, uniqueness: { scope: [:label, :scope] }
  validates :label, presence: true
  validates :scope, presence: true
end
