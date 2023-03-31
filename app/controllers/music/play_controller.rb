class Music::PlayController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	include MusicHelper

	def show
		@title = "Playing"
		pl = MusicPlaylist.where("user_id = ? AND name = 'QUEUE'", current_user.id).order('position').first
		if pl
			track = MusicTrack.find(pl.music_track_id)
			@album = track.album.html_safe
			@name = track.title.gsub(/^[0-9 ]*/, '').html_safe
			@artist = track.artist.html_safe
			@src = map_src(track.location)
		else
			@album = ''
			@name = 'QUEUE EMPTY'
			@artist = ''
			@src = ''
		end
	end

	def update
		queue = params['QUEUE']
		playlist = MusicPlaylist.where("user_id = ? AND name = 'QUEUE'", current_user.id).order('position').first
		if playlist
			track = MusicTrack.find(playlist.music_track_id)
			playlist.delete
		end
		pl = MusicPlaylist.where("user_id = ? AND name = 'QUEUE'", current_user.id).order('position').first
		if pl
			@track = MusicTrack.find(pl.music_track_id)
		else
			@track = nil
		end
		if @track
			src = map_src(@track.location)
			album = map_text(@track.album)
			name = map_text(@track.title.gsub(/^[0-9 ]*/, ''))
			artist = map_text(@track.artist)
			render json: {
				"album": album,
				"name": name,
				"artist": artist,
				"src": src
			}, status: :accepted
		else
			render json: {
				"message": "QUEUE EMPTY"
			}, status: 400
		end
	end

	private

	def map_src(v)
		return(v.gsub(/^................/, 'http://192.168.1.168').gsub(/&amp;/, '&'))
	end

	def require_music
		if ! current_user_role('music')
			redirect_to users_path, alert: "Insufficient permission: MUSICARTIST"
		end
	end

	def map_text(v)
		return( v.gsub(/&amp;/, '&').gsub(/&#xE0;/, 224.chr(Encoding::UTF_8)).gsub(/&#xF9;/, 249.chr(Encoding::UTF_8)).gsub(/&#xF2;/, 242.chr(Encoding::UTF_8)).gsub(/&#xE9;/, 233.chr(Encoding::UTF_8)).gsub(/&#x2019;/, 8217.chr(Encoding::UTF_8)).gsub(/&#xE8;/, 232.chr(Encoding::UTF_8)).gsub(/&#x2026;/, 8230.chr(Encoding::UTF_8)).gsub(/&#x9F13;/, 40723.chr(Encoding::UTF_8)).gsub(/&#x7AE5;/, 31461.chr(Encoding::UTF_8)) )
	end
      
end 
