class CreateBridgeBboTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_bbo_types do |t|
      t.string :btype

      t.timestamps
    end
  end
end
