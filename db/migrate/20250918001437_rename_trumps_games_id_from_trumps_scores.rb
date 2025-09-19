class RenameTrumpsGamesIdFromTrumpsScores < ActiveRecord::Migration[7.0]
  def change
  	rename_column :trumps_scores, :trumps_games_id, :trumps_game_id
  end
end
