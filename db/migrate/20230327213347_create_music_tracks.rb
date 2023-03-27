class CreateMusicTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :music_tracks do |t|
      t.string :title
      t.string :genre
      t.string :artist
      t.string :album
      t.integer :track_number
      t.integer :track_total
      t.integer :duration
      t.integer :file_size
      t.string :location
      t.integer :play_count
      t.string :media_type
      t.string :composer
      t.integer :disc_number
      t.integer :disc_total
      t.string :comment
      t.integer :weight

      t.timestamps
    end
  end
end
