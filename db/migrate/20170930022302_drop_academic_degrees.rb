class DropAcademicDegrees < ActiveRecord::Migration[5.0]
  def change
    drop_table :academic_degrees
  end
end
