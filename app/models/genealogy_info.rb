class GenealogyInfo < ApplicationRecord

	belongs_to :genealogy_individual

	has_many :genealogy_info_sources

end
