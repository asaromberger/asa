class Finance::Admin::ImportController < ApplicationController

	before_action :require_signed_in
	before_action :require_finance_admin

	require 'csv'

	def new
		@title = 'Import'
		@messages = []
		if params[:messages]
			params[:messages].sub(/\[/, '').sub(/\]$/, '').split(/,/).each do |message|
				@messages.push(message.gsub(/^"/, '').gsub(/"$/, ''))
			end
		end
	end

	def create
		start_time = Time.now
		@title = "Import Report"

		@messages = []
		max_message_count = 30
		badtables = Hash.new
		document = params[:document]
		if document.blank? || document.original_filename.blank?
			redirect_to new_finance_admin_import_path, alert: "No spreadsheet specified"
			return
		end

		newcounts = Hash.new
		dupcounts = Hash.new

		newcounts['expenses_accountmap'] = 0
		dupcounts['expenses_accountmap'] = 0
		finance_expenses_accountmap_ids = Hash.new
		newcounts['expenses_category'] = 0
		dupcounts['expenses_category'] = 0
		finance_expenses_category_ids = Hash.new
		newcounts['expenses_what'] = 0
		dupcounts['expenses_what'] = 0
		finance_expenses_what_ids = Hash.new
		newcounts['expenses_item'] = 0
		dupcounts['expenses_item'] = 0
		finance_expenses_item_ids = Hash.new
		newcounts['expenses_what_map'] = 0
		dupcounts['expenses_what_map'] = 0
		finance_expenses_what_map_ids = Hash.new

		newcounts['investments_account'] = 0
		dupcounts['investments_account'] = 0
		finance_investments_account_ids = Hash.new
		newcounts['investments_fund'] = 0
		dupcounts['investments_fund'] = 0
		finance_investments_fund_ids = Hash.new
		newcounts['investments_investment'] = 0
		dupcounts['investments_investment'] = 0
		finance_investments_investment_ids = Hash.new
		newcounts['investments_rebalance'] = 0
		dupcounts['investments_rebalance'] = 0
		finance_investments_rebalance_ids = Hash.new
		# ADD SUMMARY STUFF HERE

		data = CSV.open(document.tempfile, 'r')
		data.each do |line|
			if line[0] == 'expenses_accountmap'
				fam = FinanceExpensesAccountmap.where("account = ? AND ctype = ?", line[1], line[2]).first
				if ! fam
					fam = FinanceExpensesAccountmap.new
					fam.account = line[1]
					fam.ctype = line[2]
					fam.save
					newcounts['expenses_accountmap'] += 1
				else
					dupcounts['expenses_accountmap'] += 1
					if finance_accountmap_ids[fam.account]
						if @messages.count < max_message_count
							@messages.push("DUP: expenses_accountmap: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_expenses_accountmap_ids[fam.account] = fam.id
			elsif line[0] == 'expenses_category'
				if ! line[4]
					line[4] = ''
				end
				fc = FinanceExpensesCategory.where("ctype = ? AND category = ? AND subcategory = ?", line[1], line[2], line[3]).first
				if ! fc
					fc = FinanceExpensesCategory.new
					fc.ctype = line[1]
					fc.category = line[2]
					fc.subcategory = line[3]
					fc.tax = line[4]
					fc.save
					newcounts['expenses_category'] += 1
				else
					dupcounts['expenses_category'] += 1
					if finance_category_ids["#{fc.ctype}:#{fc.category}:#{fc.subcategory}"]
						if @messages.count < max_message_count
							@messages.push("DUP: expenses_category: #{fc.ctype}: #{fc.category}: #{fc.subcategory}: #{fc.tax}")
						end
					end
				end
				finance_expenses_category_ids["#{fc.ctype}:#{fc.category}:#{fc.subcategory}"] = fc.id
			elsif line[0] == 'expenses_what'
				fw = FinanceExpensesWhat.where("what = ? and finance_expenses_category_id = ?", line[1], finance_category_ids["#{line[2]}:#{line[3]}:#{line[4]}"]).first
				if ! fw
					fw = FinanceExpensesWhat.new
					fw.what = line[1]
					fw.finance_expenses_category_id = finance_category_ids["#{line[2]}:#{line[3]}:#{line[4]}"]
					fw.save
					newcounts['expenses_what'] += 1
				else
					dupcounts['expenses_what'] += 1
					if finance_what_ids[fw.what]
						if @messages.count < max_message_count
							@messages.push("DUP: expenses_what; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}")
						end
					end
				end
				finance_expenses_what_ids[fw.what] = fw.id
			elsif line[0] == 'expenses_item'
				fi = FinanceExpensesItem.where("date = ? AND pm = ? AND finance_expenses_what_id = ? AND amount = ?", line[1], line[2], finance_what_ids[line[4]], line[5]).first
				if ! fi
					fi = FinanceItem.new
					fi.date = line[1]
					fi.pm = line[2]
					fi.checkno = line[3]
					fi.finance_expenses_what_id = finance_what_ids[line[4]]
					fi.amount = line[5]
					fi.save
					newcounts['expenses_item'] += 1
				else
					dupcounts['expenses_item'] += 1
					if finance_item_ids["#{fi.date}:#{fi.pm}:#{fi.finance_expenses_what_id}:#{fi.amount}"]
						if @messages.count < max_message_count
							@messages.push("DUP: expenses_item; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}; #{line[5]}")
						end
					end
				end
				finance_expenses_item_ids["#{fi.date}:#{fi.pm}:#{fi.finance_expenses_what_id}:#{fi.amount}"] = fi.id
			elsif line[0] == 'expenses_what_map'
				fwm = FinanceExpensesWhatMap.where("whatmap = ? AND finance_expenses_what_id = ?", line[1], finance_what_ids[line[2]]).first
				if ! fwm
					fwm = FinanceExpensesWhatMap.new
					fwm.whatmap = line[1]
					fwm.finance_expenses_what_id = finance_what_ids[line[2]]
					fwm.save
					newcounts['expenses_what_map'] += 1
				else
					dupcounts['expenses_what_map'] += 1
					if finance_what_map_ids["#{line[1]}:#{line[2]}"]
						if @messages.count < max_message_count
							@messages.push("DUP: expenses_what_map: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_expenses_what_map_ids["#{line[1]}:#{line[2]}"] = fwm.id

			elsif line[0] == 'investments_account'
				fa = FinanceInvestmentsAccount.where("name = ?", line[1]).first
				if ! fa
					fa = FinanceInvestmentsAccount.new
					fa.name = line[1]
					fa.save
					newcounts['investments_account'] += 1
				else
					dupcounts['investments_account'] += 1
					if finance_investments_account_ids[fa.name]
						if @messages.count < max_message_count
							@messages.push("DUP: investments_account: #{line[1]}")
						end
					end
				end
				finance_investments_account_ids[fa.name] = fa.id
			elsif line[0] == 'investments_fund'
				ff = FinanceInvestmentsFund.where("finance_investments_account_id = ? AND fund = ? AND atype = ?", finance_investments_account_ids[line[1]], line[2], line[3]).first
				if ! ff
					ff = FinanceInvestmentsFund.new
					ff.finance_investments_account_id = finance_investments_account_ids[line[1]]
					ff.fund = line[2]
					ff.atype = line[3]
					if ! line[4].blank? && line[4] == 'true'
						ff.closed = true
					else
						ff.closed = false
					end
					ff.save
					newcounts['investments_fund'] += 1
				else
					dupcounts['investments_fund'] += 1
					if finance_investments_fund_ids[ff.fund]
						if @messages.count < max_message_count
							@messages.push("DUP: investments_fund: #{line[1]}: #{line[2]}: #{line[3]}")
						end
					end
				end
				finance_investments_fund_ids["#{line[1]}:#{ff.fund}"] = [ff.finance_investments_account_id, ff.id]
			elsif line[0] == 'investments_investment'
				fi = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ? AND date = ?", finance_investments_fund_ids["#{line[1]}:#{line[2]}"], line[3].to_date).first
				if !fi
					fi = FinanceInvestmentsInvestment.new
					fi.finance_investments_fund_id = finance_investments_fund_ids["#{line[1]}:#{line[2]}"][1]
					fi.date = line[3].to_date
					fi.value = line[4].to_f
					fi.shares = line[5].to_f
					fi.pershare = line[6].to_f
					fi.guaranteed = line[7].to_f
					fi.save
					newcounts['investments_investment'] += 1
				else
					dupcounts['investments_investment'] += 1
					if finance_investments_investment_ids["#{fi.finance_investments_fund_id}:#{fi.date}"]
						if @messages.count < max_message_count
							@messages.push("DUP: investments_investment; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}; #{line[5]}; #{line[6]}")
						end
					end
				end
				finance_investments_investment_ids["#{fi.finance_investments_fund_id}:#{fi.date}"] = fi.id
			elsif line[0] == 'investments_rebalance'
				fr = FinanceInvestmentsRebalance.where("finance_investments_fund_id = ?", finance_investments_fund_ids["#{line[1]}:#{line[2]}"]).first
				if ! fr
					fr = FinanceInvestmentsRebalance.new
					fr.finance_investments_fund_id = finance_investments_fund_ids["#{line[1]}:#{line[2]}"]
					fr.target = line[3].to_f
					fr.save
					newcounts['investments_rebalance'] += 1
				else
					dupcounts['investments_rebalance'] += 1
					if finance_investments_rebalance_ids[rt.rtype]
						if @messages.count < max_message_count
							@messages.push("DUP: investments_rebalance: #{line[1]} #{line[2]}")
						end
					end
				end
				finance_investments_rebalance_ids[finance_investments_fund_ids["#{line[1]}:#{line[2]}"]] = fr.id
#	NEEDS NEW SUMMARY STUFF
#			elsif line[0] == 'summary_type'
#				fst = FinanceSummaryType.where("stype = ?", line[1]).first
#				if ! fst
#					fst = FinanceSummaryType.new
#					fst.stype = line[1]
#					fst.priority = line[2]
#					fst.save
#					newcounts['summary_type'] += 1
#				else
#					dupcounts['summary_type'] += 1
#					if finance_summary_type_ids[fst.stype]
#						if @messages.count < max_message_count
#							@messages.push("DUP: summary_type: #{line[1]}: #{line[2]}")
#						end
#					end
#				end
#				finance_summary_type_ids[fst.stype] = fst.id
#			elsif line[0] == 'investment_map'
#				fim = FinanceInvestmentMap.where("finance_investments_fund_id = ? AND finance_summary_type_id = ?", finance_investments_fund_ids[line[1]], finance_summary_type_ids[line[2]]).first
#				if ! fim
#					fim = FinanceInvestmentMap.new
#					fim.finance_investments_fund_id = finance_investments_fund_ids[line[1]]
#					fim.finance_summary_type_id = finance_summary_type_ids[line[2]]
#					fim.save
#					newcounts['investment_map'] += 1
#				else
#					dupcounts['investment_map'] += 1
#					if finance_investment_map_ids["#{finance_investments_fund_ids[line[1]]}:#{finance_summary_type_ids[line[2]]}"]
#						if @messages.count < max_message_count
#							@messages.push("DUP: investment_map: #{line[1]}: #{line[2]}")
#						end
#					end
#					finance_investment_map_ids["#{finance_investments_fund_ids[line[1]]}:#{finance_summary_type_ids[line[2]]}"] = fim.id
#				end

			else
				if badtables[line[0]]
					badtables[line[0]] += 1
				else
					badtables[line[0]] = 1
				end
			end
		end
		if @messages.count > max_message_count
			@messages.push("EXCESSIVE DUPLICATES NOT REPORTED (#{@messages.count})")
		end
		badtables.each do |bad, count|
			@messages.push("BAD #{bad}: #{count}")
		end
		newcounts.each do |table, count|
			@messages.push("#{table}: NEW: #{count} EXISTING: #{dupcounts[table]}")
		end
		end_time = Time.now
		delta = (end_time - start_time).to_i
		seconds = delta % 60
		if seconds < 10
			seconds = "0#{seconds}"
		end
		delta = delta / 100
		minutes = delta % 60
		if minutes < 10
			minutes = "0#{minutes}"
		end
		delta = delta / 100
		if delta == 0
			@messages.push("TIME: #{minutes}:#{seconds}")
		else
			@messages.push("TIME: i#{delta}:#{minutes}:#{seconds}")
		end

		redirect_to new_finance_admin_import_path(messages: @messages.to_json)
	end

	def require_finance_admin
		unless current_user_role('finance_admin')
			redirect_to root_url, alert: "inadequate permissions: FINANCE ADMIN"
		end
	end

end
