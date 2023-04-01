class CreateGenealogyFamilies < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_families do |t|
      t.integer :husband_id
      t.integer :wife_id
      t.date :updated

      t.timestamps
    end
  end
end
