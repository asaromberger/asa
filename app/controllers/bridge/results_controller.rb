class Bridge::ResultsController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = "Bridge Scoring"
		if params[:notices]
			@notices = params[:notices]
		else
			@notices = []
		end
		@stypes = [''] + BridgeTable.all.order('stype').pluck('DISTINCT stype')
		if ! params[:date]
			@date = Time.now.to_date
		else
			@date = params[:date].to_date
		end
		@dates = BridgeResult.all.pluck("DISTINCT date")
		@stype = params[:stype]
		t = BridgeResult.where("date = ?", @date).first
		if t
			@stype = t.stype
		end
		if params[:board]
			@board = params[:board]
		else
			@board = 1
		end
		@vulnerable = BridgeBoard.where('board = ?', @board).first
		if @stype
			@results = Hash.new
			BridgeTable.where("stype = ? AND board = ?", @stype, @board).order('round').each do |table|
				result = BridgeResult.where("date = ? AND board = ? AND ns = ? AND ew = ?", @date, @board, table.ns, table.ew).first
				if ! result
					result = BridgeResult.new
					result.date = @date
					result.stype = @stype
					result.board = @board
					result.ns = table.ns
					result.ew = table.ew
					result.save
				end
				@results[result.id] = result
			end
		end
	end

	def create
		date = params[:date].to_date
		@notices = []
		stype = params[:stype]
		board = params[:board]
		params[:contract].each do |id, value|
			result = BridgeResult.find(id.to_i)
			result.contract = params[:contract][id].upcase.sub(/NT/, 'N')
			result.by = params[:by][id].upcase
			result.result = params[:result][id]
			result.nsscore = params[:nsscore][id]
			result.ewscore = params[:ewscore][id]
			result.save
		end
		correct = params[:commit] == 'correct'
		# collect results
		results = Hash.new
		BridgeResult.where("date = ? AND board = ?", date, board).each do |result|
			results[result.id] = Hash.new
			results[result.id]['contract'] = result.contract
			results[result.id]['by'] = result.by
			results[result.id]['ns'] = result.ns
			results[result.id]['ew'] = result.ew
			if result.result
				results[result.id]['result'] = result.result
			else
				results[result.id]['result'] = 0
			end
			if result.nsscore && result.nsscore > 0
				results[result.id]['nsscore'] = result.nsscore
				results[result.id]['ewscore'] = -result.nsscore
			elsif result.ewscore && result.ewscore > 0
				results[result.id]['ewscore'] = result.ewscore
				results[result.id]['nsscore'] = -result.ewscore
			else
				results[result.id]['ewscore'] = 0
				results[result.id]['nsscore'] = 0
			end
		end
		# validate scoring
		#	contract + results => score and column
		results.each do |id, values|
			# check column
			@vulnerable = BridgeBoard.where('board = ?', board).first
			if values['by'].match(/[NS]/)
				vulnerable  = @vulnerable.nsvul
				if values['result'] > 0
					if ! values['nsscore'] || values['nsscore'] <= 0
						if correct
							values['nsscore'] = - values['nsscore']
							values['ewscore'] = - values['ewscore']
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Score in wrong column")
						end
					end
				else
					if ! values['ewscore'] || values['ewscore'] <= 0
						if correct
							values['nsscore'] = - values['nsscore']
							values['ewscore'] = - values['ewscore']
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Score in wrong column")
						end
					end
				end
			elsif values['by'].match(/[EW]/)
				vulnerable  = @vulnerable.ewvul
				if values['result'] > 0
					if ! values['ewscore'] || values['ewscore'] <= 0
						if correct
							values['nsscore'] = - values['nsscore']
							values['ewscore'] = - values['ewscore']
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Score in wrong column")
						end
					end
				else
					if ! values['nsscore'] || values['nsscore'] <= 0
						if correct
							values['nsscore'] = - values['nsscore']
							values['ewscore'] = - values['ewscore']
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Score in wrong column")
						end
					end
				end
			elsif values['contract'].match('PASS')
				next
			else
				@notices.push("Pairs #{values['ns']}/#{values['ew']}: By not valid")
			end
			# check value
			level = values['contract'][0]
			if ! level || ! level.match(/[1-7]/)
				@notices.push("Pairs #{values['ns']}/#{values['ew']}: Bad Contract")
				next
			end
			level = level.to_i
			suit = values['contract'][1]
			if suit.match(/[SH]/)
				suit = 'M'
			elsif suit.match(/[DC]/)
				suit = 'm'
			elsif suit == 'N'
			else
				@notices.push("Pairs #{values['ns']}/#{values['ew']}: Bad Contract")
				next
			end
			double = values['contract'][2]
			redouble = values['contract'][3]
			if values['nsscore'] > 0
				score = values['nsscore']
			else
				score = -values['nsscore']
			end
			if suit && suit != ""
				if values['result'] > 0
					# overtricks for double/redouble
					if suit == 'M'
						if redouble
							# bid * 30 * 4
							# over nonvul * 200
							# over vul + 400
							# insult 100
							base = level * 30 * 4
							if vulnerable
								base += (values['result'] - level) * 400
							else
								base += (values['result'] - level) * 200
							end
							base += 100
							game = 1
						elsif double
							# bid * 30 * 2
							# over nonvul * 100
							# over vul + 200
							# insult 50
							base = level * 30 * 2
							if vulnerable
								base += (values['result'] - level) * 200
							else
								base += (values['result'] - level) * 100
							end
							base += 50
							game = 2
						else
							# tricks are 30
							base = values['result'] * 30
							game = 4
						end
						if level >= game
							if vulnerable
								base += 500
							else
								base += 300
							end
						else
							base += 50
						end
					elsif suit == 'm'
						if redouble
							# bid * 20 * 4
							# over nonvul * 200
							# over vul + 400
							# insult 100
							base = level * 20 * 4
							if vulnerable
								base += (values['result'] - level) * 400
							else
								base += (values['result'] - level) * 200
							end
							base += 100
							game = 2
						elsif double
							# bid * 20 * 2
							# over nonvul * 100
							# over vul + 200
							# insult 50
							base = level * 20 * 2
							if vulnerable
								base += (values['result'] - level) * 200
							else
								base += (values['result'] - level) * 100
							end
							base += 50
							game = 3
						else
							# tricks are 20
							base = values['result'] * 20
							game = 5
						end
						if level >= game
							if vulnerable
								base += 500
							else
								base += 300
							end
						else
							base += 50
						end
					else
						if redouble
							# (bid * 30 + 10) * 4
							# over nonvul * 200
							# over vul + 400
							# insult 100
							base = (level * 30 + 10) * 4
							if vulnerable
								base += (values['result'] - level) * 400
							else
								base += (values['result'] - level) * 200
							end
							base += 100
							game = 1
						elsif double
							# (bid * 30 + 10) * 2
							# over nonvul * 100
							# over vul + 200
							# insult 50
							base = (level * 30 + 10) * 2
							if vulnerable
								base += (values['result'] - level) * 200
							else
								base += (values['result'] - level) * 100
							end
							base += 50
							game = 2
						else
							# tricks are 30 + 10 for first
							base = values['result'] * 30 + 10
							game = 3
						end
						if level >= game
							if vulnerable
								base += 500
							else
								base += 300
							end
						else
							base += 50
						end
					end
					if level == 6
						if vulnerable
							base += 750
						else
							base += 500
						end
					elsif level == 7
						if vulnerable
							base += 1500
						else
							base += 1000
						end
					end
					if base != score
						if correct
							if values['nsscore'] > 0
								values['nsscore'] = base
							else
								values['ewscore'] = base
							end
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Bad Score, expected #{base}")
						end
						next
					end
				elsif values['result'] < 0
					down = -values['result']
					if ! double
						# not doubled
						if vulnerable
							base = down * 100
						else
							base = down * 50
						end
					else
						# doubled & redoubled
						if vulnerable
							if down == 1
								base = down
							else
								base = 200 + 300 * (down - 1)
							end
						else
							if down == 1
								base = 100
							elsif down <= 3
								base = 100 + (down - 1) * 200
							else
								base = 500 + (down - 3) * 300
							end
						end
						if redouble
							base = base * 2
						end
					end
					if base != score
						if correct
							if values['nsscore'] > 0
								values['nsscore'] = base
							else
								values['ewscore'] = base
							end
						else
							@notices.push("Pairs #{values['ns']}/#{values['ew']}: Bad Score, expected #{base}")
						end
						next
					end
				end
			end
		end
		# calculate points
		results.each do |id, values|
			values['nspoints'] = 0
			values['ewpoints'] = 0
			results.each do |xid, xvalues|
				if id != xid
					if values['nsscore'] > xvalues['nsscore']
						values['nspoints'] += 1
					elsif values['nsscore'] == xvalues['nsscore']
						values['nspoints'] += 0.5
					end
					if values['ewscore'] > xvalues['ewscore']
						values['ewpoints'] += 1
					elsif values['ewscore'] == xvalues['ewscore']
						values['ewpoints'] += 0.5
					end
				end
			end
			result = BridgeResult.find(id)
			if values['nsscore'] > 0
				result.nsscore = values['nsscore']
				result.ewscore = nil
			end
			if values['ewscore'] > 0
				result.ewscore = values['ewscore']
				result.nsscore = nil
			end
			result.nspoints = values['nspoints']
			result.ewpoints = values['ewpoints']
			result.save
		end
		puts("NOTICES: #{@notices.to_json}")
		if @notices.count > 0
			redirect_to bridge_results_path(date: date, stype: stype, board: board.to_i, notices: @notices), alert: "Errors"
		else
			redirect_to bridge_results_path(date: date, stype: stype, board: board.to_i + 1)
		end
	end

	def update
		date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
		redirect_to bridge_results_path(date: date, stype: params[:stype], board: params[:board])
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
