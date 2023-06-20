class Finance::Investments::RebalanceTypesController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Manage Rebalance Types'
		@rebalance_types = FinanceRebalanceType.all.order('rtype')
	end

	def show
		@rebalance_type = FinanceRebalanceType.find(params[:id])
		@title = "Funds in #{@rebalance_type.rtype}"
		@funds = Hash.new
		FinanceInvestmentsFund.where("closed IS NULL OR closed = false").order('fund').each do |fund|
			@funds[fund.id] = Hash.new
			fia = FinanceInvestmentsAccount.find(fund.finance_investments_account_id)
			@funds[fund.id]['name'] = "#{fia.name}: #{fund.fund}"
			@funds[fund.id]['included'] = false
		end
		FinanceRebalanceMap.where("finance_rebalance_type_id = ?", @rebalance_type.id).each do |map|
			if @funds.key?(map.finance_investments_fund_id)
				@funds[map.finance_investments_fund_id]['included'] = true
				@funds[map.finance_investments_fund_id]['target'] = map.target
			end
		end
		@funds = @funds.sort_by { |id, values| values['name'].downcase }
	end

	def showupdate
		@rebalance_type = FinanceRebalanceType.find(params[:rebalance_type])
		total = 0
		FinanceInvestmentsFund.all.each do |fund|
			rebalance_map = FinanceRebalanceMap.where("finance_rebalance_type_id = ? AND finance_investments_fund_id = ?", @rebalance_type.id, fund.id)
			if rebalance_map.count > 0
				rebalance_map.delete_all
			end
			if params[fund.id.to_s] == 'on'
				target = params["target#{fund.id}"].to_f
				total = total + target
				rebalance_map = FinanceRebalanceMap.new
				rebalance_map.finance_rebalance_type_id = @rebalance_type.id
				rebalance_map.finance_investments_fund_id = fund.id
				rebalance_map.target = target
				rebalance_map.save
			end
		end
		if total == 1
			redirect_to finance_investments_rebalance_types_path, notice: "#{@rebalance_type.rtype} updated"
		else
			redirect_to finance_investments_rebalance_types_path, alert: "#{@rebalance_type.rtype} totals to #{total}"
		end
	end

	def new
		@title = 'New Rebalance Type'
		@rebalance_type = FinanceRebalanceType.new
	end

	def create
		if FinanceRebalanceType.where("rtype = ?", params[:finance_rebalance_type][:rtype]).count > 0
			redirect_to finance_investments_rebalance_types_path, alert: 'Rebalance Type already exists'
		else
			@rebalance_type = FinanceRebalanceType.new(rebalance_type_params)
			if @rebalance_type.save
				redirect_to finance_investments_rebalance_types_path, notice: 'Rebalance Type Added'
			else
				redirect_to finance_investments_rebalance_types_path, alert: 'Failed to create Rebalance Type'
			end
		end
	end

	def edit
		@title = 'Edit Rebalance Type'
		@rebalance_type = FinanceRebalanceType.find(params[:id])
	end

	def update
		if FinanceRebalanceType.where("rtype = ?", params[:finance_rebalance_type][:rtype]).count > 0
			redirect_to finance_investments_rebalance_types_path, alert: 'Rebalance Type already exists'
		else
			@rebalance_type = FinanceRebalanceType.find(params[:id])
			if @rebalance_type.update(rebalance_type_params)
				redirect_to finance_investments_rebalance_types_path, notice: 'Rebalance Type Updated'
			else
				redirect_to finance_investments_rebalance_types_path, alert: 'Failed to update Rebalance Type'
			end
		end
	end

	def destroy
		@rebalance_type = FinanceRebalanceType.find(params[:id])
		FinanceRebalanceMap.where("finance_rebalance_type_id = ?", params[:id]).delete_all
		@rebalance_type.delete
		redirect_to finance_investments_rebalance_types_path, notice: "Rebalance Type #{@rebalance_type.rtype} Deleted"
	end

private
	
	def rebalance_type_params
		params.require(:finance_rebalance_type).permit(:rtype)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS REBALANCETYPES"
		end
	end

end
