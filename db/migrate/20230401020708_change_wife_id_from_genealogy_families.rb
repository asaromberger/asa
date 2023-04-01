class ChangeWifeIdFromGenealogyFamilies < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_families, :wife_id, :genealogy_wife_id
  end
end
