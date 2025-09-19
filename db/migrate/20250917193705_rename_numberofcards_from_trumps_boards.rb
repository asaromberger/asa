class RenameNumberofcardsFromTrumpsBoards < ActiveRecord::Migration[7.0]
  def change
  	rename_column :trumps_boards, :trummps_numberofcards, :numberofcards
  end
end
