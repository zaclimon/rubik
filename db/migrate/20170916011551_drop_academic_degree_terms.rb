class DropAcademicDegreeTerms < ActiveRecord::Migration[5.0]
  def change
    drop_table :academic_degree_terms
  end
end
