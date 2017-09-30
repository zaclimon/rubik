# frozen_string_literal: true
class EtsPdf::Etl::GroupTermTagBuilder < EtsPdf::Etl::TermTagBuilder
  GROUPS = {
    "anciens" => "Anciens Étudiants",
    "nouveaux" => "Nouveaux Étudiants",
  }
  IGNORE = %w(tous)

  def initialize(term, units)
    super term, units, :group, GROUPS, IGNORE
  end
end
