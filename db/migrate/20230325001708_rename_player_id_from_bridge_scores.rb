class RenamePlayerIdFromBridgeScores < ActiveRecord::Migration[7.0]
  def change
  	rename_column :bridge_scores, :player_id, :bridge_player_id
  end
end
