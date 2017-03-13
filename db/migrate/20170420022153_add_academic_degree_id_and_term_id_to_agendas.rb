class AddAcademicDegreeIdAndTermIdToAgendas < ActiveRecord::Migration[5.0]
  def change
    add_column :agendas, :academic_degree_id, :integer
    add_column :agendas, :term_id, :integer
  end
end
