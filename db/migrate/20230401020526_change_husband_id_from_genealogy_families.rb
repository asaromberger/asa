class ChangeHusbandIdFromGenealogyFamilies < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_families, :husband_id, :genealogy_husband_id
  end
end
