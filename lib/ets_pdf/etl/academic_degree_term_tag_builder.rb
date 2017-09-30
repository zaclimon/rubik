# frozen_string_literal: true
class EtsPdf::Etl::AcademicDegreeTermTagBuilder < EtsPdf::Etl::TermTagBuilder
  ACADEMIC_DEGREES = {
    "seg" => "Enseignements généraux",
    "ctn" => "Génie de la construction",
    "ele" => "Génie électrique",
    "log" => "Génie logiciel",
    "mec" => "Génie mécanique",
    "gol" => "Génie des opérations et de la logistique",
    "gpa" => "Génie de la production automatisée",
    "gti" => "Génie des technologies de l'information",
  }.freeze

  def initialize(term, units)
    super term, units, :academic_degree, ACADEMIC_DEGREES
  end
end
