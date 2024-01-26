class RenameBtypeFromBridgeBbos < ActiveRecord::Migration[7.0]
  def change
	remove_column :bridge_bbos, :btype
	add_column :bridge_bbos, :bridge_bbo_type_id, :integer
  end
end
