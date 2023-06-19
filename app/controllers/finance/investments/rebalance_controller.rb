class Finance::Investments::RebalanceController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Rebalance Fund Groups'
		@rebalances = FinanceRebalanceType.all.order('rtype')
	end

	def show
		@rebalance = FinanceRebalanceType.find(params[:id])
		@title = "Rebalance #{@rebalance.rtype}"
		@funds = Hash.new
		FinanceRebalanceMap.joins(:finance_investments_fund).where("finance_rebalance_type_id = ?", @rebalance.id).order('fund').each do |map|
			@funds[map.finance_investments_fund_id] = Hash.new
			@funds[map.finance_investments_fund_id]['name'] = map.finance_investments_fund.fund
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", map.finance_investments_fund_id).order('date DESC')
			if investment.count > 0
				@funds[map.finance_investments_fund_id]['value'] = investment.first.value
			else
				@funds[map.finance_investments_fund_id]['value'] = 0
			end
			@funds[map.finance_investments_fund_id]['target'] = map.target
		end
	end

	def showupdate
		@rebalance = FinanceRebalanceType.find(params[:id])
		@title = "Rebalance #{@rebalance.rtype}"
		@funds = Hash.new
		@total = 0
		# get fund information
		FinanceRebalanceMap.joins(:finance_investments_fund).where("finance_rebalance_type_id = ?", @rebalance.id).order('fund').each do |map|
			@funds[map.finance_investments_fund_id] = Hash.new
			@funds[map.finance_investments_fund_id]['name'] = map.finance_investments_fund.fund
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", map.finance_investments_fund_id).order('date DESC')
			if investment.count > 0
				@funds[map.finance_investments_fund_id]['value'] = investment.first.value
			else
				@funds[map.finance_investments_fund_id]['value'] = 0
			end
			@funds[map.finance_investments_fund_id]['target'] = map.target
			@total = @total + @funds[map.finance_investments_fund_id]['value']
		end
		withdraw = params[:withdraw].to_f

		@total = @total - withdraw
		# calculate amount to move to/from each fund
		@funds.each do |id, fund|
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
