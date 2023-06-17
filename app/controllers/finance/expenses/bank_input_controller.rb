class Finance::Expenses::BankInputController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	require 'csv'

	def edit
		@title = 'Bank Input'
		@accounts = [['','']]
		FinanceAccountmap.all.order('ctype').pluck('DISTINCT ctype').each do |type|
		@accounts.push([type, type])
		end
	end

	def create
		# this is file input. input goes to input table then to new
		# clear input table
		FinanceInput.delete_all
		@title = 'Classify Bank Input'
		@document = params[:document]
		@documentname = @document.original_filename
		if @documentname.blank?
			redirect_to edit_finance_expenses_bank_input_path(id: 0), alert: "No file specified"
			return
		end
		@input = File.open(@document.tempfile, 'rb').read.gsub(/[\r\n]+/, "\n")
		lines = CSV.parse(@input)
		@errors = []
		if lines[0][0] && lines[0][0].gsub(/:.*/, '') == 'OFXHEADER'
			# Quicken input
			accountmap = Hash.new
			FinanceAccountmap.all.each do |map|
				accountmap[map.account] = map.ctype
			end
			# remerge lines
			lines = @input.split("<");
			type = '';
			date = '';
			amount = '';
			pm = '';
			fitid = '';
			check = '';
			what = '';
			account = 'UNKNOWN';
			lines.each do |line|
				key = line.gsub(/>.*/, '')
				line = line.gsub(/.*>/, '')
				if key == 'DTPOSTED'
					posted = line
					year = line[0..3]
					month = line[4..5]
					day = line[6..7]
					date = "#{year}-#{month}-#{day}"
				elsif key == 'TRNAMT'
					amount = line
					if amount[0..0] == '-'
						pm = '-'
						amount = amount.gsub(/-/, '')
					else
						pm = '+'
					end
				elsif key == 'CHECKNUM'
					check = line
				elsif key == 'NAME'
					what = line.gsub(/&amp;/, '&')
				elsif key == '/STMTTRN'
					what = "#{account}:#{what}"
					input = FinanceInput.new
					input.date = date
					input.pm = pm
					input.checkno = check
					input.what = what
					input.amount = amount
					input.save
					type = '';
					date = '';
					amount = '';
					pm = '';
					fitid = '';
					check = '';
					what = '';
				elsif key == 'ACCTID'
					if accountmap[line].blank?
						@errors.push("UNKNOWN ACCOUNT: #{line}")
						account = 'UNKNOWN'
					else
						account = accountmap[line]
					end
				end
			end
		else
			if params[:account].blank?
				redirect_to edit_finance_expenses_bank_input_path(id: 0), alert: "Need to specify an account"
				return
			else
				@account = params[:account] + ':'
			end
			# CSV File Input
			if lines[0][0].blank?
				# old style, no headers
				datefield = 2
				whatfield = 4
				altwhatfield = 3
				amountfield = 6
			else
				# new style, find headers
				datefield = ''
				whatfield = ''
				altwhatfield = ''
				amountfield = ''
				i = 0
				lines[0].each do |field|
					if field.match(/Date/)
						datefield = i
					elsif field.match(/Original Description/)
						whatfield = i
						checkfield = 1
					elsif field.match(/Description/)
						altwhatfield = i
						checkfield = 1
					elsif field.match(/Amount/)
						amountfield = i
					end
					i = i + 1
				end
				header = 1
				if datefield.blank? || whatfield.blank? || amountfield.blank?
					$errors.push("Cannot locate fields")
					redirect_to new_finance_expenses_bank_input_path(documentname: @documentname, errors: @errors)
					return
				end
			end
			lines = lines.reverse
			lines.each do |fields|
				if fields[datefield].match(/Date/)
					next
				end
				if fields[datefield]
					if fields[whatfield]
						what = @account + fields[whatfield].gsub(/^"*\s*/, '').gsub(/\s*"*$/, '')
					else
						what = @account + fields[altwhatfield].gsub(/^"*\s*/, '').gsub(/\s*"*$/, '')
					end
					if what.match('CHECK')
						check = what.gsub(/.*#\s*/, '').gsub(/\s*$/, '')
					else
						check = ''
					end
					amount = fields[amountfield].gsub(/^"*\s*/, '').gsub(/\s*"*$/, '')
					if amount[0] == '-'
						pm = '-'
						amount = amount.gsub(/-/, '')
					else
						pm = '+'
					end
					date = fields[datefield]
					datesep = date.split("/")
					if datesep[0].to_i > 100
						month = datesep[1]
						day = datesep[2]
						year = datesep[0]
					elsif datesep[2].to_i > 100
						month = datesep[0]
						day = datesep[1]
						year = datesep[2]
					else
						@errors.push("BAD DATE: #{date}")
						month = '01'
						day = '01'
						year = '1000'
						next
					end
					date = "#{year}-#{month}-#{day}"
					input = FinanceInput.new
					input.date = date
					if input.date.blank?
						@errors.push("BAD DATE: #{date}")
					else
						input.pm = pm
						input.checkno = check
						input.what = what
						input.amount = amount
						input.save
					end
				else
					if line != '_'
						@errors.push("BAD LINE: #{line}")
					end
				end
			end
		end
		redirect_to new_finance_expenses_bank_input_path(documentname: @documentname, errors: @errors)
	end

	def new
		# classification page
		@title = 'Classify Bank Input'
		if params[:errors]
			@errors = params[:errors]
		else
			@errors = []
		end
		@documentname = params[:documentname]
		if params[:table]
			# process current categorization
			params[:table].each do |id, values|
				date = values['date']
				pm = values['pm']
				check = values['check']
				what = values['what']
				amount = values['amount']
				mapto = values['mapto']
				whatmap = values['whatmap'].to_i
				category = values['category'].to_i
				if mapto.blank?
					newwhat = what
				else
					newwhat = mapto
				end
				if category > 0
					twhat = FinanceWhat.where("what = ?", newwhat)
					if twhat.count == 0
						twhat = FinanceWhat.new
						twhat.what = newwhat
						twhat.finance_category_id = category
						twhat.save
					end
					whatmap = FinanceWhat.where("what = ?", newwhat).first.id
				end
				if ! mapto.blank?
					twhatmap = FinanceWhatMap.joins(:finance_what).where("whatmap = ? AND finance_whats.what = ?", what, mapto)
					if twhatmap.count == 0
						# need to create a new map
						twhat = FinanceWhat.where("what = ?", mapto)
						if twhat.count > 0
							whatmap = twhat.first.id
							twhatmap = FinanceWhatMap.new
							twhatmap.whatmap = what
							twhatmap.finance_what_id = whatmap
							twhatmap.save
						end
					end
					newwhat = mapto
				else
					newwhat = what
				end
				item = FinanceExpensesItem.joins(:finance_what).where("date = ? AND pm = ? AND checkno = ? AND what = ? AND amount = ?", date, pm, check, newwhat, amount)
				if whatmap > 0
					if item.count > 0
						item = item.first
					else
						item = FinanceExpensesItem.new
						item.date = date
						item.pm = pm
						item.checkno = check
						item.amount = amount
					end
					item.finance_what_id = whatmap
					item.save
				end
			end
		end
		# generate next batch from input table
		@exist = 0
		@table = Hash.new
		lineno = 0
		maxlines = 30
		FinanceInput.all.order('date').each do |input|
			date = input.date
			pm = input.pm
			check = input.checkno
			what = input.what
			amount = input.amount
			whatlist = [what]
			FinanceWhatMap.where("whatmap = ?", what).each do |map|
				whatlist.push(map.finance_what.what)
			end
			item = FinanceExpensesItem.joins(:finance_what).where("date = ? AND pm = ? AND checkno = ? AND what IN (?) AND amount = ?", date, pm, check, whatlist, amount)
			if item.count > 0
				@exist = @exist + 1
				input.delete
			else
				lineno = lineno + 1
				@table[lineno] = Hash.new
				@table[lineno]['date'] = date
				@table[lineno]['pm'] = pm
				@table[lineno]['check'] = check
				@table[lineno]['what'] = what
				@table[lineno]['amount'] = amount
				@table[lineno]['whatmaplist'] = [['', 0]]
				FinanceWhatMap.where("whatmap = ?", what).each do |wl|
					@table[lineno]['whatmaplist'].push([wl.finance_what.what, wl.finance_what_id])
				end
				if @table[lineno]['whatmaplist'].count == 2
					@table[lineno]['whatmap'] = @table[lineno]['whatmaplist'][1][1]
				else
					@table[lineno]['whatmap'] = 0
				end
				twhat = FinanceWhat.where("what = ?", what)
				if twhat.count > 0
					@table[lineno]['category'] = twhat.first.finance_category_id
				else
					@table[lineno]['category'] = 0
				end
			end
			if lineno == maxlines
				@errors.push("Only showing #{maxlines} lines")
				break
			end
		end
		@categorylist = [['', 0]]
		FinanceCategory.all.order('ctype, category, subcategory, tax').each do |category|
			@categorylist.push(["#{category.ctype}/#{category.category}/#{category.subcategory}/#{category.tax}", category.id])
		end
		if @table.count == 0
			#redirect_to edit_finance_expenses_bank_input_path(id: 0), notice: "File #{@documentname} is complete"
		end
	end

private

	def parse(line)
		flag = 0
		ind = 0
		while line[ind]
			field = ''
			if line[ind] == '"'
				ind = ind + 1
				while line[ind] && line[ind] != '"'
					field = field + line[ind]
					ind = ind + 1
				end
				ind = ind + 2
			else
				while line[ind] && ! line[ind].match(/[,\r\n]/)
					field = field + line[ind]
					ind = ind + 1
				end
				ind = ind + 1
			end
			if flag == 0
				if field == ''
					next
				end
				date = field
				flag = 1
			elsif flag == 1
				checkno = field
				flag = 2
			elsif flag == 2
				what = field
				flag = 3
			elsif flag == 3
				flag = 4
			else
				amount = field
				return [date, checkno, what, amount]
			end
		end
		return []
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES BANK INPUT"
		end
	end

end
