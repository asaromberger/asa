class Music::SyncController < ApplicationController

	before_action :require_signed_in
	before_action :require_music

	# landing page
	def index
		@title = "Sync Report"
		@output = []
		db = Hash.new
		MusicTrack.all.each do |track|

			db[track.location] = track
		end
		datafile = "app/assets/templates/rhythmdb.xml"
		data = File.read(datafile).split(/\n/)
		track = false
ignore = false
		title = ''
		weight = 0
		genre = ''
		artist = ''
		album = ''
		track_number = 0
		track_total = 0
		duration = 0
		file_size = 0
		location = ''
		play_count = 0
		media_type = ''
		composer = ''
		disc_number = 0
		disc_total = 0
		comment = ''
		new = 0
		update = 0
		data.each do |line|
			field = line.sub(/^\s*</, '').sub(/>.*/, '')
			content = line.sub(/^\s*<[^>]*>/, '').sub(/<.*/, '')
			if field == 'entry type="song"'
				track = true
			elsif field == 'entry type="iradio"'
				ignore = true
			elsif field == 'entry type="ignore"'
				ignore = true
			elsif field == 'title'
				title = content
			elsif field == 'genre'
				genre = content
			elsif field == 'artist'
				artist = content
			elsif field == 'album'
				album = content
			elsif field == 'track-number'
				track_number = content
			elsif field == 'track-total'
				track_total = content
			elsif field == 'duration'
				duration = content
			elsif field == 'file-size'
				file_size = content
			elsif field == 'location'
				location = content
			elsif field == 'mountpoint'
			elsif field == 'mtime'
			elsif field == 'first-seen'
			elsif field == 'last-seen'
			elsif field == 'play-count'
				play_count = content
			elsif field == 'last-played'
			elsif field == 'bitrate'
			elsif field == 'date'
			elsif field == 'media-type'
				media_type = content
			elsif field == 'composer'
				composer = content
			elsif field == 'disc-number'
				disc_number = content
			elsif field == 'disc-total'
				disc_total = content
			elsif field == 'comment'
				comment = content
			elsif field == 'hidden'
			elsif field == 'mb-trackid'
			elsif field == 'mb-artistid'
			elsif field == 'mb-albumid'
			elsif field == 'mb-albumartistid'
			elsif field == 'mb-artistsortname'
			elsif field == 'album-artist'
			elsif field == 'album-sortname'
			elsif field == '/entry'
				if track
					if db[location]
						update += 1
						table = db[location]
						db.delete(location)
					else
						new += 1
						table = MusicTrack.new
						table.title = title
						table.weight = 10
					end
					table.genre = genre
					table.artist = artist
					table.album = album
					table.track_number = track_number
					table.track_total = track_total
					table.duration = duration
					table.file_size = file_size
					table.location = location
					table.play_count = play_count
					table.media_type = media_type
					table.composer = composer
					table.disc_number = disc_number
					table.disc_total = disc_total
					table.comment = comment
					table.save
					track = false
					title = ''
					weight = 0
					genre = ''
					artist = ''
					album = ''
					track_number = 0
					track_total = 0
					duration = 0
					file_size = 0
					location = ''
					play_count = 0
					media_type = ''
					composer = ''
					disc_number = 0
					disc_total = 0
					comment = ''
				elsif ignore
					ignore = false
				else
					@output.push("INVALID: #{title}")
				end
			else
				@output.push(line)
			end
		end
		@output.push("NEW: #{new}")
		@output.push("UPDATE: #{update}")
		@output.push("OUT OF DATE: #{db.count}")
		db.each do |location, track|
			track.delete
		end
	end

	private
      
	def require_music
		if ! current_user_role('music')
			redirect_to users_path, alert: "Insufficient permission: MUSICSYNC"
		end
	end

end

