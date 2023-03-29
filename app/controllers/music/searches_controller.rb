class Music::SearchesController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	include MusicHelper

	# search box
	def new
		@title = "Search"
	end

	def index
		@title = "Search Results"
		search = "%#{params[:search]}%"
		@artists = Hash.new
		@albums = Hash.new
		@songs = Hash.new
		MusicTrack.where("LOWER(title) LIKE ? OR LOWER(album) LIKE ? OR LOWER(artist) LIKE ?", search, search, search).each do |song|
			@artists[song.artist] = song.artist
			@albums[song.album] = song.album
			@songs[song.location] = song
		end
		@artists = @artists.sort_by { |index, value| index.downcase }
		@albums = @albums.sort_by { |index, value| index.downcase }
		@songs = @songs.sort_by { |index, song| song.title.gsub(/^[0-9]* */, '').downcase }
	end

	# add song to play queue
	def create
		# find  current last
		position = find_position('QUEUE')
		pl = Playlist.new
		pl.user_id = current_user.id
		pl.name = 'QUEUE'
		pl.music_track_id = params[:id].to_i
		pl.position = position
		pl.save
		album = MusicTrack.find(pl.music_track_id).album
		redirect_to music_album_path(id:0, album: album), notice: "Added"
	end

	private
      
	def require_music
		if ! current_user_role('music')
			redirect_to new_session_path, alert: "Insufficient permission: MUSICARTIST"
		end
	end

end

