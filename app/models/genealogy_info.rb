class GenealogyInfo < ApplicationRecord

# baptism [date] [place]
# birth [date] [place]
# burried [date] [place]
# census [date] [place]
# death [date] [place]
# event [date] [place] {note (=NULL), type (=NULL)}
# name date=nul place=nil {given, suffix, surname}
# occupation [date] [place]
# residence [date] [place]

	belongs_to :genealogy_individual

	has_many :genealogy_info_sources

end

