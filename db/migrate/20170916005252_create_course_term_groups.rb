# frozen_string_literal: true
class CreateCourseTermGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :course_term_groups do |t|
      t.references :course_term
      t.integer :number
      t.text :periods
      t.timestamps
    end
  end
end
