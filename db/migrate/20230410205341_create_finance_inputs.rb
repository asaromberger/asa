class CreateFinanceInputs < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_inputs do |t|
      t.date :date
      t.string :pm
      t.string :checkno
      t.string :what
      t.decimal :amount

      t.timestamps
    end
  end
end
