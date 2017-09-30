class AddTermIdToAgendas < ActiveRecord::Migration[5.0]
  def change
    add_reference :agendas, :term, after: :id, index: true
  end
end
