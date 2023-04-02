class GenealogyChild < ApplicationRecord

	belongs_to :genealogy_individual
	belongs_to :genealogy_family

end
