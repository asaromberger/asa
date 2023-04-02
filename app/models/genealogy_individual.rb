class GenealogyIndividual < ApplicationRecord

	has_many :genealogy_children
	has_many :genealogy_infos

end
