class Finance::Investments::RebalanceController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Rebalance Accounts'
		@accounts = FinanceInvestmentsAccount.all.order('name')
	end

	def edit
		@account = FinanceInvestmentsAccount.find(params[:id])
		@title = "Rebalance #{@account}"
		fund_ids = []
		@funds = Hash.new
		FinanceInvestmentsFund.where("finance_investments_account_id = ?", @account.id).each do |fund|
			@funds[fund.id] = Hash.new
			@funds[fund.id]['name'] = "#{@account.name}: #{fund.fund}"
			@funds[fund.id]['target'] = nil
			fund_ids.push(fund.id)
		end
		FinanceInvestmentsRebalance.where("finance_investments_fund_id IN (?)", fund_ids).each do |rebalance|
			@funds[rebalance.finance_investments_fund_id]['target'] = rebalance.target
		end
	end

	def update
		@account = FinanceInvestmentsAccount.find(params[:id])
		@title = "Rebalance #{@account}"
		target = 0
		FinanceInvestmentsFund.where("finance_investments_account_id = ?", @account.id).each do |fund|
			rebalance = FinanceInvestmentsRebalance.where("finance_investments_fund_id = ?", fund.id).first
			if params["target#{fund.id}"] && params["target#{fund.id}"] != ''
				if ! rebalance
					rebalance = FinanceInvestmentsRebalance.new
					rebalance.finance_investments_fund_id = fund.id
				end
				rebalance.target = params["target#{fund.id}"].to_f
				rebalance.save
				target += rebalance.target
			else
				if rebalance
					rebalance.delete
				end
			end
		end
		if target == 1
			redirect_to finance_investments_rebalance_path(@account.id), notice: "Rebalance updated"
		else
			redirect_to edit_finance_investments_rebalance_path(@account.id), alert: "Rebalance does not total to 1"
		end
	end

	def show
		@account = FinanceInvestmentsAccount.find(params[:id])
		@title = "Rebalance #{@account.name}"
		fund_ids = []
		@funds = Hash.new
		FinanceInvestmentsFund.where("finance_investments_account_id = ?", @account.id).each do |fund|
			@funds[fund.id] = Hash.new
			@funds[fund.id]['name'] = "#{@account.name}: #{fund.fund}"
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", fund.id).order('date DESC').first
			if investment
				@funds[fund.id]['value'] = investment.value
			else
				@funds[fund.id]['value'] = 0
			end
			@funds[fund.id]['target'] = nil
			fund_ids.push(fund.id)
		end
		FinanceInvestmentsRebalance.where("finance_investments_fund_id IN (?)", fund_ids).each do |rebalance|
			@funds[rebalance.finance_investments_fund_id]['target'] = rebalance.target
		end
	end

	def showupdate
		@account = FinanceInvestmentsAccount.find(params[:id])
		@title = "Rebalance #{@account.name}"
		fund_ids = []
		@funds = Hash.new
		@total = 0
		# get fund information
		FinanceInvestmentsFund.where("finance_investments_account_id = ?", @account.id).each do |fund|
			@funds[fund.id] = Hash.new
			@funds[fund.id]['name'] = "#{@account.name}: #{fund.fund}"
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", fund.id).order('date DESC').first
			if investment
				@funds[fund.id]['value'] = investment.value
			else
				@funds[fund.id]['value'] = 0
			end
			@funds[fund.id]['target'] = nil
			fund_ids.push(fund.id)
		end
		FinanceInvestmentsRebalance.where("finance_investments_fund_id IN (?)", fund_ids).each do |rebalance|
			@funds[rebalance.finance_investments_fund_id]['target'] = rebalance.target
			@total += @funds[rebalance.finance_investments_fund_id]['value']
		end
		withdraw = params[:withdraw].to_f

		@total = @total - withdraw
		# calculate amount to move to/from each fund
		@funds.each do |id, fund|
			if fund['target']
				t = @total * fund['target']
				@funds[id]['target'] = t
				@funds[id]['move'] = t - fund['value'];
				if @funds[id]['value'] > @funds[id]['target']
					@funds[id]['sell'] = @funds[id]['value'] - @funds[id]['target']
					@funds[id]['buy'] = ''
				else
					@funds[id]['sell'] = ''
					@funds[id]['buy'] = @funds[id]['target'] - @funds[id]['value']
				end
			else
				@funds.delete(id)
			end
		end
		@withdraws = []
		@transfers = []
		if params[:withdraw_only]
			# withdrawals only
			if withdraw > 0
				excess = 0
				@funds.each do |id, fund|
					if fund['move'] < 0
						excess -= fund['move']
					end
				end
				@funds.each do |id, fund|
					if fund['move'] < 0
						t = - (fund['move'] * withdraw / excess);
						@withdraws.push([t,fund['name']])
					end
				end
			end
		else
			# withdrawals and transfers
			# withdraws
			if withdraw > 0
				@funds.each do |id, fund|
					if withdraw > 0 && fund['move'] < 0
						if withdraw > -fund['move']
							t = -fund['move']
						else
							t = withdraw
						end
						@withdraws.push([t, fund['name']])
						@funds[id]['move'] = @funds[id]['move'] + t
						withdraw = withdraw - t
					end
				end
			end
			# transfers
			@funds.each do |fid, ffund|
				@funds.each do |tid, tfund|
					if @funds[fid]['move'] < 0
						if tfund['move'] > 0
							if -ffund['move'] > tfund['move']
								t = tfund['move']
							else
								t = -ffund['move']
							end
							@transfers.push([t, ffund['name'], tfund['name']]);
							@funds[fid]['move'] = @funds[fid]['move'] + t
							@funds[tid]['move'] = @funds[tid]['move'] - t
						end
					end
				end
			end
		end
	end

private

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS REBALANCE"
		end
	end

	end
