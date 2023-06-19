class Finance::Investments::SummaryController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		if params[:fromyear]
			@fromyear = params[:fromyear]
		else
			@fromyear = Time.now.year - 10
		end
		if params[:toyear]
			@toyear = params[:toyear]
		else
			@toyear = FinanceInvestmentsInvestment.all.order('date DESC').first.date.year
		end
		@title = "Investments Summary"
		@pickyears = []
		FinanceInvestmentsInvestment.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
			@pickyears.push(year.to_i)
		end
		@pickyears = @pickyears.sort
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
		@summaries = Hash.new
		FinanceSummaryType.all.order('priority').each do |summary|
			@summaries[summary.id] = Hash.new
			@summaries[summary.id]['name'] = summary.stype
			@summaries[summary.id]['priority'] = summary.priority
			@years.each do |year|
				@summaries[summary.id][year] = 0
			end
			FinanceInvestmentMap.where("finance_summary_type_id = ?", summary.id).each do |map|
				t = Hash.new
				FinanceInvestmentsInvestment.where("finance_investments_fund_id = ? AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", map.finance_investments_fund_id, @fromyear, @toyear).order('date').each do |investment|
					t[investment.date.year] = investment.value
				end
				@years.each do |year|
					if t[year]
						@summaries[summary.id][year] = @summaries[summary.id][year] + t[year]
					elsif t[year - 1]
						@summaries[summary.id][year] = @summaries[summary.id][year] + t[year - 1]
					end
				end
			end
		end
	end

	def show
		@summarytype = FinanceSummaryType.find(params[:id])
		@title = "Fund contributions for #{@summarytype.stype}"
		@fromyear = params[:fromyear]
		@toyear = params[:toyear]
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
		@funds = Hash.new
		FinanceInvestmentMap.joins(:finance_investments_fund).where("finance_summary_type_id = ?", @summarytype.id).order('fund').each do |map|
			@funds[map.finance_investments_fund_id] = Hash.new
			@funds[map.finance_investments_fund_id]['name'] = map.finance_investments_fund.fund
			@years.each do |year|
				@funds[map.finance_investments_fund_id][year] = 0
			end
			FinanceInvestmentsInvestment.where("finance_investments_fund_id = ? AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", map.finance_investments_fund_id, @fromyear, @toyear).order('date').each do |investment|
				@funds[map.finance_investments_fund_id][investment.date.year] = investment.value
			end
			flag = 0
			@years.each do |year|
				if @funds[map.finance_investments_fund_id][year] != 0
					flag = 1
				end
			end
			if flag == 0
				@funds.delete(map.finance_investments_fund_id)
			end
		end
	end

private

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS SUMMARY"
		end
	end

end
