class ChangeIndividualIdFromGenealogyInfos < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_infos, :individual_id, :genealogy_individual_id
  end
end
