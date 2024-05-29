class BridgeBoard < ApplicationRecord

	validates :board, uniqueness: true

end
