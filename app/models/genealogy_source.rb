class GenealogySource < ApplicationRecord

	belongs_to :repo

	has_many :genealogy_info_sources

end
