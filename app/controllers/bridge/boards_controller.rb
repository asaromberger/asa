class Bridge::BoardsController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = "Duplicate Bridge Boards"
		@boards = BridgeBoard.all.order('board')
	end

	# create a new player
	def new
		@board = BridgeBoard.new
	end

	def create
		@board = BridgeBoard.new(board_params)
		if @board.save
			redirect_to bridge_boards_path, notice: "Board added"
		else
			redirect_to bridge_boards_path, Alert: "Failed to add board"
		end
	end

	# edit player
	def edit
		@board = BridgeBoard.find(params[:id])
	end

	def update
		@board = BridgeBoard.find(params[:id])
		if @board.update(board_params)
			redirect_to bridge_boards_path, notice: "Board #{@board.board} Updated"
		else
			redirect_to bridge_boards_path, alert: "Failed to update Board #{@board.board}"
		end
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

	def board_params
		params.require(:bridge_board).permit(:board, :nsvul, :ewvul)
	end

end
