class Finance::Investments::SummaryManagementController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Manage Summaries'
		@summaries = FinanceInvestmentsSummary.all.order('priority')
	end

	def show
		@summary = FinanceInvestmentsSummary.find(params[:id])
		@title = "Accounts in #{@summary.stype}"
		@accounts = Hash.new
		FinanceInvestmentsAccount.all.each do |account|
			@accounts[account.id] = Hash.new
			@accounts[account.id]['name'] = account.name
			if FinanceInvestmentsSummaryContent.where("finance_investments_account_id = ? AND finance_investments_summary_id = ?", account.id, @summary.id).count > 0
				@accounts[account.id]['included'] = true
			else
				@accounts[account.id]['included'] = false
			end
		end
		@accounts = @accounts.sort_by { |id, values| values['name'].downcase }
	end

	def showupdate
		@summary = FinanceInvestmentsSummary.find(params[:summary])
		FinanceInvestmentsAccount.all.each do |account|
			content = FinanceInvestmentsSummaryContent.where("finance_investments_summary_id = ? AND finance_investments_account_id = ?", @summary.id, account.id)
			if params[account.id.to_s] == 'on'
				if content.count == 0
					content = FinanceInvestmentsSummaryContent.new
					content.finance_investments_summary_id = @summary.id
					content.finance_investments_account_id = account.id
					content.save
				end
			else
				if content.count > 0
					content.first.delete
				end
			end
		end
		redirect_to finance_investments_summary_management_path(@summary.id), notice: "#{@summary.stype} updated"
	end

	def new
		@title = 'New Summary'
		@summary = FinanceInvestmentsSummary.new
	end

	def create
		if FinanceInvestmentsSummary.where("stype = ?", params[:finance_investments_summary][:stype]).count > 0
			redirect_to finance_investments_summary_management_index_path, alert: 'Summary already exists'
		else
			@summary = FinanceInvestmentsSummary.new(summary_params)
			if @summary.save
				redirect_to finance_investments_summary_management_index_path, notice: 'Summary Added'
			else
				redirect_to finance_investments_summary_management_index_path, alert: 'Failed to create Summary'
			end
		end
	end

	def edit
		@title = 'Edit Summary'
		@summary = FinanceInvestmentsSummary.find(params[:id])
	end

	def update
		@summary = FinanceInvestmentsSummary.find(params[:id])
		if @summary.update(summary_params)
			redirect_to finance_investments_summary_management_index_path, notice: 'Summary Updated'
		else
			redirect_to finance_investments_summary_management_index_path, alert: 'Failed to update Summary'
		end
	end

	def destroy
		@summary = FinanceInvestmentsSummary.find(params[:id])
		FinanceInvestmentsSummaryContent.where("finance_investments_summary_id = ?", @summary.id).delete_all
		@summary.delete
		redirect_to finance_investments_summary_management_index_path, notice: "Summary #{@summary.stype} Deleted"
	end

private
	
	def summary_params
		params.require(:finance_investments_summary).permit(:stype, :priority)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS SUMMARYTYPES"
		end
	end

end
