class Music::AlbumsController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	include MusicHelper

	def index
		@title = "Albums"
		@music = Hash.new
		MusicTrack.all.order('album, track_number').each do |track|
			if ! @music[track.album]
				@music[track.album] = true
			end
		end
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

	# add album to play queue
	def update
		position = find_position('QUEUE')
		album = params[:album]
		MusicTrack.where("album = ?", album).order('track_number').each do |track|
			pl = MusicPlaylist.new
			pl.user_id = current_user.id
			pl.name = 'QUEUE'
			pl.music_track_id = track.id
			pl.position = position
			pl.save
			position += 1
		end
		redirect_to music_albums_path, notice: "Added"
	end

	def show
		@album = params[:album]
		@title = @album.html_safe
		@music = Hash.new
		MusicTrack.where("album = ?", @album).order('track_number').each do |track|
			@music[track.location] = track
		end
	end

	private
      
	def require_music
		if ! current_user_role('music')
			redirect_to users_path, alert: "Insufficient permission: MUSICALBUM"
		end
	end

end

