class ChangeFamilyIdFromGenealogyChildren < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_children, :family_id, :genealogy_family_id
  end
end
