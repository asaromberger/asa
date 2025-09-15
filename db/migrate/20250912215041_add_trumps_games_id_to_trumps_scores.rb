class AddTrumpsGamesIdToTrumpsScores < ActiveRecord::Migration[7.0]
  def change
    add_column :trumps_scores, :trumps_games_id, :integer
  end
end
