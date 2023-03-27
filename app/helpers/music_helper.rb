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

end
