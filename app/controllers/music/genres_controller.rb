class Music::GenresController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	include MusicHelper

	def index
	@title = "Genres"
		@music = Hash.new
		MusicTrack.all.order('genre, artist, album, track_number').each do |song|
			list = song.genre.split(/\s+/)
			list.each do |genre|
				genre = genre.downcase
				if ! @music[genre]
					@music[genre] = true
				end
			end
		end
		@music = @music.sort_by { |genre, values| genre }
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
		genre = MusicTrack.find(pl.music_track_id).genre
		redirect_to genre_path(id:0, genre:genre), notice: "Added"
	end

	# add all by this genre to play queue
	def update
		position = find_position('QUEUE')
		genre = "%#{params[:genre]}%"
		MusicTrack.where("LOWER(genre) LIKE ?", genre).order('genre, artist, album, track_number').each do |song|
			pl = Playlist.new
			pl.user_id = current_user.id
			pl.name = 'QUEUE'
			pl.music_track_id = song.id
			pl.position = position
			pl.save
			position += 1
		end
		redirect_to genres_path, notice: "Added"
	end

	def show
		@title = params[:genre].html_safe
		@music = Hash.new
		@genre = params[:genre].html_safe
		genre = "%#{params[:genre]}%"
		MusicTrack.where("LOWER(genre) LIKE ?", genre).order('genre, artist, album, track_number').each do |song|
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

