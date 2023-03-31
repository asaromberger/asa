class CreateMusicPlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :music_playlists do |t|
      t.integer :user_id
      t.string :name
      t.integer :music_track_id
      t.integer :position

      t.timestamps
    end
  end
end
