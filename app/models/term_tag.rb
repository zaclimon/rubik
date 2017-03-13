# frozen_string_literal: true
class TermTag < ApplicationRecord
  belongs_to :term
  has_many :course_term_group_term_tags
end
