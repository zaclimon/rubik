# frozen_string_literal: true
class GroupTermTag < ApplicationRecord
  belongs_to :group, inverse_of: :term_tags
  belongs_to :term_tag

  validates :group, presence: true, uniqueness: { scope: :term_tag }
  validates :term_tag, presence: true
end
