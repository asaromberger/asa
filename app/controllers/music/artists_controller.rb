class Music::ArtistsController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	include MusicHelper

	def index
		@title = "Artists"
		@music = Hash.new
		MusicTrack.all.order('artist, album, track_number').each do |song|
			if ! @music[song.artist]
				@music[song.artist] = true
			end
		end
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
		artist = MusicTrack.find(pl.music_track_id).artist
		redirect_to artist_path(id: 0, artist: artist), notice: "Added"
	end

	# add all by this artist to play queue
	def update
		position = find_position('QUEUE')
		artist = params[:artist]
		MusicTrack.where("artist = ?", artist).order('artist, album, track_number').each do |song|
			pl = Playlist.new
			pl.user_id = current_user.id
			pl.name = 'QUEUE'
			pl.music_track_id = song.id
			pl.position = position
			pl.save
			position += 1
		end
		redirect_to artists_path, notice: "Added"
	end

	def show
		@artist = params[:artist]
		@title = @artist.html_safe
		@music = Hash.new
		MusicTrack.where("artist = ?", @artist).order('artist, album, track_number').each do |song|
			@music[song.location] = song
		end
	end

	private
      
	def require_music
		if ! current_user_role('music')
			redirect_to new_session_path, alert: "Insufficient permission: MUSICARTIST"
		end
	end

end

