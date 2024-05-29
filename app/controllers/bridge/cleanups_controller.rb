class Bridge::CleanupsController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = "Clean Up Old Results"
		@results = BridgeResult.all.group(:date).pluck('date, count(id)')
	end

	def show
		date = params[:id].to_date
		@results = BridgeResult.where("date = ?", date).order('date, board')
	end

	def destroy
		date = params[:id].to_date
		BridgeResult.where("date = ?", date).delete_all
		redirect_to bridge_cleanups_path, notice: "Removed #{date}"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
