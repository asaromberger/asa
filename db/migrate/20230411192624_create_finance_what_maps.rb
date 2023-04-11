class CreateFinanceWhatMaps < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_what_maps do |t|
      t.string :whatmap
      t.integer :finance_what_id

      t.timestamps
    end
  end
end
