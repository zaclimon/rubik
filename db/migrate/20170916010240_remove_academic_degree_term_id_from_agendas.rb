class RemoveAcademicDegreeTermIdFromAgendas < ActiveRecord::Migration[5.0]
  def change
    remove_column :agendas, :academic_degree_term_id, :integer
  end
end
