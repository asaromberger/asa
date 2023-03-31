class Music::PlaylistsController < ApplicationController

	before_action :require_signed_in

	def index
		@title = "Queue"
		@music = Hash.new
		MusicPlaylist.where("user_id = ? AND name = 'QUEUE'", current_user.id).order('position').each do |item|
			@music[item.position] = MusicTrack.find(item.music_track_id)
		end
	end

	def destroy
		if params[:id].to_i == 0
			MusicPlaylist.where("user_id = ? AND name = 'QUEUE'", current_user.id).delete_all
		else
			pl = MusicPlaylist.where("user_id = ? AND name = 'QUEUE' AND position = ?", current_user.id, params[:id].to_i).first
		end
		if pl
			pl.delete
		end
		redirect_to music_playlists_path, notice: "Removed"
	end

	private
      
end

