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
		newcounts['accountmap'] = 0
		dupcounts['accountmap'] = 0
		finance_accountmap_ids = Hash.new
		newcounts['account'] = 0
		dupcounts['account'] = 0
		finance_account_ids = Hash.new
		newcounts['category'] = 0
		dupcounts['category'] = 0
		finance_category_ids = Hash.new
		newcounts['rebalance_types'] = 0
		dupcounts['rebalance_types'] = 0
		finance_rebalance_types_ids = Hash.new
		newcounts['summary_type'] = 0
		dupcounts['summary_type'] = 0
		finance_summary_type_ids = Hash.new
		newcounts['investment_map'] = 0
		dupcounts['investment_map'] = 0
		finance_investment_map_ids = Hash.new
		newcounts['investment'] = 0
		dupcounts['investment'] = 0
		finance_investment_ids = Hash.new
		newcounts['rebalance_map'] = 0
		dupcounts['rebalance_map'] = 0
		finance_rebalance_map_ids = Hash.new
		newcounts['what'] = 0
		dupcounts['what'] = 0
		finance_what_ids = Hash.new
		newcounts['item'] = 0
		dupcounts['item'] = 0
		finance_item_ids = Hash.new
		newcounts['what_map'] = 0
		dupcounts['what_map'] = 0
		finance_what_map_ids = Hash.new
		data = CSV.open(document.tempfile, 'r')
		data.each do |line|
			if line[0] == 'accountmap'
				fam = FinanceExpensesAccountmap.where("account = ? AND ctype = ?", line[1], line[2]).first
				if ! fam
					fam = FinanceExpensesAccountmap.new
					fam.account = line[1]
					fam.ctype = line[2]
					fam.save
					newcounts['accountmap'] += 1
				else
					dupcounts['accountmap'] += 1
					if finance_accountmap_ids[fam.account]
						if @messages.count < max_message_count
							@messages.push("DUP: accountmap: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_accountmap_ids[fam.account] = fam.id
			elsif line[0] == 'account'
				fa = FinanceAccount.where("account = ? AND atype = ?", line[1], line[2]).first
				if ! fa
					fa = FinanceAccount.new
					fa.account = line[1]
					fa.atype = line[2]
					if ! line[3].blank? && line[3] == 'true'
						fa.closed = true
					else
						fa.closed = false
					end
					fa.save
					newcounts['account'] += 1
				else
					dupcounts['account'] += 1
					if finance_account_ids[fa.account]
						if @messages.count < max_message_count
							@messages.push("DUP: account: #{line[1]}: #{line[2]}: #{line[3]}")
						end
					end
				end
				finance_account_ids[fa.account] = fa.id
			elsif line[0] == 'category'
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
					newcounts['category'] += 1
				else
					dupcounts['category'] += 1
					if finance_category_ids["#{fc.ctype}:#{fc.category}:#{fc.subcategory}"]
						if @messages.count < max_message_count
							@messages.push("DUP: category: #{fc.ctype}: #{fc.category}: #{fc.subcategory}: #{fc.tax}")
						end
					end
				end
				finance_category_ids["#{fc.ctype}:#{fc.category}:#{fc.subcategory}"] = fc.id
			elsif line[0] == 'rebalance_types'
				frt = FinanceRebalanceType.where("rtype = ?", line[1]).first
				if ! frt
					frt = FinanceRebalanceType.new
					frt.rtype = line[1]
					frt.save
					newcounts['rebalance_types'] += 1
				else
					dupcounts['rebalance_types'] += 1
					if finance_rebalance_types_ids[frt.rtype]
						if @messages.count < max_message_count
							@messages.push("DUP: rebalance_types: #{line[1]}")
						end
					end
				end
				finance_rebalance_types_ids[frt.rtype] = frt.id
			elsif line[0] == 'summary_type'
				fst = FinanceSummaryType.where("stype = ?", line[1]).first
				if ! fst
					fst = FinanceSummaryType.new
					fst.stype = line[1]
					fst.priority = line[2]
					fst.save
					newcounts['summary_type'] += 1
				else
					dupcounts['summary_type'] += 1
					if finance_summary_type_ids[fst.stype]
						if @messages.count < max_message_count
							@messages.push("DUP: summary_type: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_summary_type_ids[fst.stype] = fst.id
			elsif line[0] == 'investment_map'
				fim = FinanceInvestmentMap.where("finance_account_id = ? AND finance_summary_type_id = ?", finance_account_ids[line[1]], finance_summary_type_ids[line[2]]).first
				if ! fim
					fim = FinanceInvestmentMap.new
					fim.finance_account_id = finance_account_ids[line[1]]
					fim.finance_summary_type_id = finance_summary_type_ids[line[2]]
					fim.save
					newcounts['investment_map'] += 1
				else
					dupcounts['investment_map'] += 1
					if finance_investment_map_ids["#{finance_account_ids[line[1]]}:#{finance_summary_type_ids[line[2]]}"]
						if @messages.count < max_message_count
							@messages.push("DUP: investment_map: #{line[1]}: #{line[2]}")
						end
					end
					finance_investment_map_ids["#{finance_account_ids[line[1]]}:#{finance_summary_type_ids[line[2]]}"] = fim.id
				end
			elsif line[0] == 'investment'
				fi = FinanceInvestment.where("finance_account_id = ? AND date = ?", finance_account_ids[line[1]], line[2].to_date).first
				if !fi
					fi = FinanceInvestment.new
					fi.finance_account_id = finance_account_ids[line[1]]
					fi.date = line[2].to_date
					fi.value = line[3].to_f
					fi.shares = line[4].to_f
					fi.pershare = line[5].to_f
					fi.guaranteed = line[6].to_f
					fi.save
					newcounts['investment'] += 1
				else
					dupcounts['investment'] += 1
					if finance_investment_ids["#{fi.finance_account_id}:#{fi.date}"]
						if @messages.count < max_message_count
							@messages.push("DUP: investment; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}; #{line[5]}; #{line[6]}")
						end
					end
				end
				finance_investment_ids["#{fi.finance_account_id}:#{fi.date}"] = fi.id
			elsif line[0] == 'rebalance_map'
				frm = FinanceRebalanceMap.where("finance_rebalance_type_id = ? AND finance_account_id = ?", finance_rebalance_types_ids[line[1]], finance_account_ids[line[2]]).first
				if ! frm
					frm = FinanceRebalanceMap.new
					frm.finance_rebalance_type_id = finance_rebalance_types_ids[line[1]]
					frm.finance_account_id = finance_account_ids[line[2]]
					frm.target = line[3]
					frm.save
					newcounts['rebalance_map'] += 1
				else
					dupcounts['rebalance_map'] += 1
					if finance_rebalance_map_ids["#{finance_rebalance_types_ids[line[1]]}:#{finance_account_ids[line[2]]}"]
						if @messages.count < max_message_count
							@messages.push("DUP: rebalance_map: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_rebalance_map_ids["#{finance_rebalance_types_ids[line[1]]}:#{finance_account_ids[line[2]]}"] = frm.id
			elsif line[0] == 'what'
				fw = FinanceWhat.where("what = ? and finance_expenses_category_id = ?", line[1], finance_category_ids["#{line[2]}:#{line[3]}:#{line[4]}"]).first
				if ! fw
					fw = FinanceWhat.new
					fw.what = line[1]
					fw.finance_expenses_category_id = finance_category_ids["#{line[2]}:#{line[3]}:#{line[4]}"]
					fw.save
					newcounts['what'] += 1
				else
					dupcounts['what'] += 1
					if finance_what_ids[fw.what]
						if @messages.count < max_message_count
							@messages.push("DUP: what; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}")
						end
					end
				end
				finance_what_ids[fw.what] = fw.id
			elsif line[0] == 'item'
				fi = FinanceExpensesItem.where("date = ? AND pm = ? AND finance_what_id = ? AND amount = ?", line[1], line[2], finance_what_ids[line[4]], line[5]).first
				if ! fi
					fi = FinanceItem.new
					fi.date = line[1]
					fi.pm = line[2]
					fi.checkno = line[3]
					fi.finance_what_id = finance_what_ids[line[4]]
					fi.amount = line[5]
					fi.save
					newcounts['item'] += 1
				else
					dupcounts['item'] += 1
					if finance_item_ids["#{fi.date}:#{fi.pm}:#{fi.finance_what_id}:#{fi.amount}"]
						if @messages.count < max_message_count
							@messages.push("DUP: item; #{line[1]}; #{line[2]}; #{line[3]}; #{line[4]}; #{line[5]}")
						end
					end
				end
				finance_item_ids["#{fi.date}:#{fi.pm}:#{fi.finance_what_id}:#{fi.amount}"] = fi.id
			elsif line[0] == 'what_map'
				fwm = FinanceExpensesWhatMap.where("whatmap = ? AND finance_what_id = ?", line[1], finance_what_ids[line[2]]).first
				if ! fwm
					fwm = FinanceExpensesWhatMap.new
					fwm.whatmap = line[1]
					fwm.finance_what_id = finance_what_ids[line[2]]
					fwm.save
					newcounts['what_map'] += 1
				else
					dupcounts['what_map'] += 1
					if finance_what_map_ids["#{line[1]}:#{line[2]}"]
						if @messages.count < max_message_count
							@messages.push("DUP: what_map: #{line[1]}: #{line[2]}")
						end
					end
				end
				finance_what_map_ids["#{line[1]}:#{line[2]}"] = fwm.id
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
