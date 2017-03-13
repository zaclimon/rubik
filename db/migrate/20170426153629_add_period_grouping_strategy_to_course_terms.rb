class AddPeriodGroupingStrategyToCourseTerms < ActiveRecord::Migration[5.0]
  def change
    add_column :course_terms, :period_pivots, :text
  end
end
