class GenealogySource < ApplicationRecord

	belongs_to :genealogy_repo

	has_many :genealogy_info_sources

end
