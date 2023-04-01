class ChangeSourceIdFromGenealogyInfoSources < ActiveRecord::Migration[7.0]
  def change
  	rename_column :genealogy_info_sources, :source_id, :genealogy_source_id
  end
end
