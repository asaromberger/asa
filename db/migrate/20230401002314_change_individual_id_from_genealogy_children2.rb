class ChangeIndividualIdFromGenealogyChildren2 < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_children, :individual_id, :genealogy_individual_id
  end
end
