class CreateAgendaTermTags < ActiveRecord::Migration[5.0]
  def change
    create_table :agenda_term_tags do |t|
      t.references :agenda
      t.references :term_tag
      t.timestamps
    end
  end
end
