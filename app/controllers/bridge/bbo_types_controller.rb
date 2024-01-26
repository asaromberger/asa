class Bridge::BboTypesController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'BBO Types'
		@types = BridgeBboType.all.order('btype')
	end

	# create a new type
	def new
		@title = "New Type"
		@type = BridgeBboType.new
	end

	def create
		btype = params[:bridge_bbo_type][:btype]
		@type = BridgeBboType.where("btype = ?", btype)
		if @type.count > 0
			redirect_to bridge_bbo_types_path, alert: "Type #{btype} Already Exists"
		else
			@type = BridgeBboType.new
			@type.btype = btype
			@type.save
				redirect_to new_bridge_bbo_types_path, notice: "Type #{btype} Added"
		end
	end

	# edit type
	def edit
		@title = "Edit Type"
		@type = BridgeBboType.find(params[:id])
	end

	def update
		btype = params[:bridge_bbo_type][:btype]
		@type = BridgeBboType.find(params[:id])
		@type.btype = btype
		@type.save
		redirect_to bridge_bbo_types_path, notice: "Type #{btype} Updated"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEBBOTYPE"
		end
	end

end
