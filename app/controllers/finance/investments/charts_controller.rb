class Finance::Investments::ChartsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@fromyear = params[:fromyear]
		@toyear = params[:toyear]
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
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
		FinanceInvestmentsSummary.all.order('priority').each do |summary|
			@summaries[summary.id] = Hash.new
			@summaries[summary.id]['name'] = summary.stype
			@summaries[summary.id]['priority'] = summary.priority
			@years.each do |year|
				@summaries[summary.id][year] = 0
			end
			t = Hash.new
			@years.each do |year|
				t[year] = Hash.new
			end
			FinanceInvestmentsSummaryContent.where("finance_investments_summary_id = ?", summary.id).each do |map|
				fund_ids = FinanceInvestmentsFund.where("finance_investments_account_id = ?", map.finance_investments_account_id).pluck('id')
				FinanceInvestmentsInvestment.where("finance_investments_fund_id IN (?) AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", fund_ids, @fromyear, @toyear).order('date').each do |investment|
					t[investment.date.year][investment.finance_investments_fund_id] = investment.value
				end
			end
			tt = Hash.new
			t.each do |year, funds|
				tt[year] = 0
				funds.each do |fund, value|
					tt[year] += value
				end
			end
			@years.each do |year|
				if tt[year]
					@summaries[summary.id][year] = @summaries[summary.id][year] + tt[year]
				elsif tt[year - 1]
					@summaries[summary.id][year] = @summaries[summary.id][year] + tt[year - 1]
				end
			end
		end
	end

private

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS CHARTS"
		end
	end

end
