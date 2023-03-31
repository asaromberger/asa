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
		@tracks = Hash.new
		MusicTrack.where("LOWER(title) LIKE ? OR LOWER(album) LIKE ? OR LOWER(artist) LIKE ?", search, search, search).each do |track|
			@artists[track.artist] = track.artist
			@albums[track.album] = track.album
			@tracks[track.location] = track
		end
		@artists = @artists.sort_by { |index, value| index.downcase }
		@albums = @albums.sort_by { |index, value| index.downcase }
		@tracks = @tracks.sort_by { |index, track| track.title.gsub(/^[0-9]* */, '').downcase }
	end

	# add track to play queue
	def create
		# find  current last
		position = find_position('QUEUE')
		pl = MusicPlaylist.new
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
			redirect_to users_path, alert: "Insufficient permission: MUSICARTIST"
		end
	end

end

