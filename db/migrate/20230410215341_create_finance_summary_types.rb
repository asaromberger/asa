class CreateFinanceSummaryTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_summary_types do |t|
      t.string :stype
      t.integer :priority

      t.timestamps
    end
  end
end
