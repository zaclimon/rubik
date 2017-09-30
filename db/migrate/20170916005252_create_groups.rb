# frozen_string_literal: true
class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.references :course_term
      t.integer :number
      t.text :periods
      t.timestamps
    end
  end
end
