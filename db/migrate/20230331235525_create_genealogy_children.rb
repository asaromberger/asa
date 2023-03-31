class CreateGenealogyChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_children do |t|
      t.integer :individual_id
      t.integer :family_id

      t.timestamps
    end
  end
end
