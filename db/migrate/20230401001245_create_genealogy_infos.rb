class CreateGenealogyInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_infos do |t|
      t.integer :individual_id
      t.string :itype
      t.date :date
      t.string :place
      t.hstore :data
      t.string :note

      t.timestamps
    end
  end
end
