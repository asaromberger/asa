class Finance::Investments::RebalanceController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Rebalance Account Groups'
		@rebalances = FinanceRebalanceType.all.order('rtype')
	end

	def show
		@rebalance = FinanceRebalanceType.find(params[:id])
		@title = "Rebalance #{@rebalance.rtype}"
		@accounts = Hash.new
		FinanceRebalanceMap.joins(:finance_account).where("finance_rebalance_type_id = ?", @rebalance.id).order('account').each do |map|
			@accounts[map.finance_account_id] = Hash.new
			@accounts[map.finance_account_id]['name'] = map.finance_account.account
			investment = FinanceInvestment.where("finance_account_id = ?", map.finance_account_id).order('date DESC')
			if investment.count > 0
				@accounts[map.finance_account_id]['value'] = investment.first.value
			else
				@accounts[map.finance_account_id]['value'] = 0
			end
			@accounts[map.finance_account_id]['target'] = map.target
		end
	end

	def showupdate
		@rebalance = FinanceRebalanceType.find(params[:id])
		@title = "Rebalance #{@rebalance.rtype}"
		@accounts = Hash.new
		@total = 0
		# get account information
		FinanceRebalanceMap.joins(:finance_account).where("finance_rebalance_type_id = ?", @rebalance.id).order('account').each do |map|
			@accounts[map.finance_account_id] = Hash.new
			@accounts[map.finance_account_id]['name'] = map.finance_account.account
			investment = FinanceInvestment.where("finance_account_id = ?", map.finance_account_id).order('date DESC')
			if investment.count > 0
				@accounts[map.finance_account_id]['value'] = investment.first.value
			else
				@accounts[map.finance_account_id]['value'] = 0
			end
			@accounts[map.finance_account_id]['target'] = map.target
			@total = @total + @accounts[map.finance_account_id]['value']
		end
		withdraw = params[:withdraw].to_f

		@total = @total - withdraw
		# calculate amount to move to/from each account
		@accounts.each do |id, account|
			t = @total * account['target']
			@accounts[id]['target'] = t
			@accounts[id]['move'] = t - account['value'];
			if @accounts[id]['value'] > @accounts[id]['target']
				@accounts[id]['sell'] = @accounts[id]['value'] - @accounts[id]['target']
				@accounts[id]['buy'] = ''
			else
				@accounts[id]['sell'] = ''
				@accounts[id]['buy'] = @accounts[id]['target'] - @accounts[id]['value']
			end
		end
		@withdraws = []
		@transfers = []
		if params[:withdraw_only]
			# withdrawals only
			if withdraw > 0
				excess = 0
				@accounts.each do |id, account|
					if account['move'] < 0
						excess -= account['move']
					end
				end
				@accounts.each do |id, account|
					if account['move'] < 0
						t = - (account['move'] * withdraw / excess);
						@withdraws.push([t,account['name']])
					end
				end
			end
		else
			# withdrawals and transfers
			# withdraws
			if withdraw > 0
				@accounts.each do |id, account|
					if withdraw > 0 && account['move'] < 0
						if withdraw > -account['move']
							t = -account['move']
						else
							t = withdraw
						end
						@withdraws.push([t, account['name']])
						@accounts[id]['move'] = @accounts[id]['move'] + t
						withdraw = withdraw - t
					end
				end
			end
			# transfers
			@accounts.each do |fid, faccount|
				@accounts.each do |tid, taccount|
					if @accounts[fid]['move'] < 0
						if taccount['move'] > 0
							if -faccount['move'] > taccount['move']
								t = taccount['move']
							else
								t = -faccount['move']
							end
							@transfers.push([t, faccount['name'], taccount['name']]);
							@accounts[fid]['move'] = @accounts[fid]['move'] + t
							@accounts[tid]['move'] = @accounts[tid]['move'] - t
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
