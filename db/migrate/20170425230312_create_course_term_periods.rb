class CreateCourseTermPeriods < ActiveRecord::Migration[5.0]
  def change
    create_table :course_term_periods do |t|
      t.references :course_term
      t.integer :group
      t.string :type
      t.decimal :frequency
      t.integer :phase
      t.integer :starts_at
      t.integer :ends_at
      t.timestamps
    end
  end
end
