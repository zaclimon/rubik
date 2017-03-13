# frozen_string_literal: true
class AgendaTermTag < ApplicationRecord
  belongs_to :agenda
  belongs_to :term_tag
end
