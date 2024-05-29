class AddStypeToBridgeResults < ActiveRecord::Migration[7.0]
  def change
    add_column :bridge_results, :stype, :string
	BridgeResult.all.each do |result|
		result.stype = '3table'
		result.save
	end
  end
end
