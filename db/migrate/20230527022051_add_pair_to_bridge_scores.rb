class AddPairToBridgeScores < ActiveRecord::Migration[7.0]
  def change
    add_column :bridge_scores, :pair, :integer
  end
end
