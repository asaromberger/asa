class CreateBridgeBbos < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_bbos do |t|
      t.date :date
      t.string :btype
      t.string :bbo_id
      t.decimal :score
      t.decimal :rank
      t.decimal :points

      t.timestamps
    end
  end
end
