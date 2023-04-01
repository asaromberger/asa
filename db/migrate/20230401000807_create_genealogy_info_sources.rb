class CreateGenealogyInfoSources < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_info_sources do |t|
      t.integer :info_id
      t.integer :source_id
      t.string :page
      t.integer :quay
      t.string :note

      t.timestamps
    end
  end
end
