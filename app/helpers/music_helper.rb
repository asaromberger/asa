module MusicHelper

    def find_position(name)
		last = MusicPlaylist.where("user_id = ? AND name = ?", current_user.id, name).order('position DESC').first
		if last
			position = last.position + 1
		else
			position = 1
		end
		return(position)
    end

	def seconds_to_time(seconds)
		secs = seconds % 60
		if secs < 10
			secs = "0#{secs}"
		end
		minutes = seconds / 60
		mins = minutes % 60
		if mins < 10
			mins = "0#{mins}"
		end
		hours = seconds / 3600
		if hours > 0
			return("#{hours}:#{mins}:#{secs}")
		else
			return("#{mins}:#{secs}")
		end
	end

end
