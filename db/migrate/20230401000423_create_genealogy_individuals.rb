class CreateGenealogyIndividuals < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_individuals do |t|
      t.integer :uid
      t.integer :refn
      t.string :sex
      t.date :updated

      t.timestamps
    end
  end
end
