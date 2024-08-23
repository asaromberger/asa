class AddEmailToBridgePlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :bridge_players, :email, :string
  end
end
