class UpdateHealthData < ActiveRecord::Migration[7.0]
  def change
  	rename_column :health_data, :calories, :aerobic_calories
	add_column :health_data, :active_calories, :integer
	add_column :health_data, :resting_calories, :integer
  end
end
