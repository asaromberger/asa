class CreateHealthData < ActiveRecord::Migration[7.0]
  def change
    create_table :health_data do |t|
      t.integer :user_id
      t.date :date
      t.integer :resistance
      t.integer :calories
      t.integer :weight
      t.integer :steps
      t.integer :flights
      t.integer :miles

      t.timestamps
    end
  end
end
