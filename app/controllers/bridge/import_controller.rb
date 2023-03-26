class Bridge::ImportController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	require 'csv'

	# read import file name
	def new
		@title = "Import"
	end

	def create
		@title = "Import Report"
		document = params[:document]
		if document.blank? || document.original_filename.blank?
			redirect_to new_import_path, alert: "No spreadsheet specified"
			return
		end
		@errors = []
		@dates = [0]
		new_player_count = 0
		new_score_count = 0
		update_score_count = 0
		flag = 0
		data = CSV.open(document.tempfile, 'r')
		data.each do |line|
			# line[0] = Date, line[1] = Player, line[2] = Score
			if flag == 0
				if trim(line[0]) != 'Date'
					redirect_to new_bridge_import_path, alert: "First column must be 'Date'"
					return
				end
				if trim(line[1]) != 'Player'
					redirect_to new_bridge_import_path, alert: "Second column must be 'Player'"
					return
				end
				if trim(line[2]) != 'Score'
					redirect_to new_bridge_import_path, alert: "Third column must be 'Score'"
					return
				end
				flag = 1
				next
			end
			date = trim(line[0]).to_date
			player = BridgePlayer.find_by(name: trim(line[1]))
			if ! player
				player = BridgePlayer.new
				player.name = trim(line[1])
				player.save
				new_player_count += 1
			end
			score = BridgeScore.where("bridge_player_id = ? AND date = ?", player.id, date)
			if score.count > 0
				score = score.first
				new_score_count += 1
			else
				score = BridgeScore.new
				score.date = date
				score.bridge_player_id = player.id
				update_score_count += 1
			end
			score.score = trim(line[2]).to_f
			score.save
		end
		@errors.push("#{new_player_count} New Players")
		@errors.push("#{new_score_count} New Scores")
		@errors.push("#{update_score_count} Updated Scores")
	end

private

	def trim(str)
		return(str.gsub(/^\s*/, '').gsub(/\s*$/, ''))
	end

	def require_bridge
		if ! current_user_role('bridge')
			redirect_to users_path, alert: "Insufficient permission: IMPORTS"
		end
	end

end