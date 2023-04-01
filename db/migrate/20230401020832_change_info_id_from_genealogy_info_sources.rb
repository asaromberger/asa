class ChangeInfoIdFromGenealogyInfoSources < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_info_sources, :info_id, :genealogy_info_id
  end
end
