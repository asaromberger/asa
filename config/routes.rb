Rails.application.routes.draw do
	# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

	# Defines the root path route ("/")
	# root "articles#index"

	root 'sessions#new'

	resources :data_checker
	resources :password_resets
	resources :roles
	resources :schema
	resources :sessions
	resources :users

	namespace :health do
		resources :data
		resources :import
		resources :plots
		resources :stats
	end

	match '/bridge/score/date', to: 'bridge/scores#date', via: 'get', as: 'bridge_score_date'
	match '/bridge/score/player', to: 'bridge/scores#player', via: 'get', as: 'bridge_score_player'
	match '//bridgescore/players_export', to: 'bridge/scores#players_export', via: 'get', as: 'bridge_score_players_export'
	match '/bridge/score/scores_export', to: 'bridge/scores#scores_export', via: 'get', as: 'bridge_score_scores_export'
	match '/bridge/pairs_score/date', to: 'bridge/pairs_scores#date', via: 'get', as: 'bridge_pairs_score_date'
	match '/bridge/pairs_score/pair', to: 'bridge/pairs_scores#pair', via: 'get', as: 'bridge_pairs_score_pair'

	namespace :bridge do
		resources :import
		resources :players
		resources :scores
		resources :pairs_scores
	end

	namespace :music do
		resources :albums
		resources :artists
		resources :genres
		resources :play
		resources :playlists
		resources :searches
		resources :sync
	end

	namespace :genealogy do
		resources :children
		resources :individuals
		resources :information
		resources :infos
		resources :info_sources
		resources :marrieds
		resources :parents
		resources :repos
		resources :search
		resources :sources
		resources :tree

		namespace :admin do
			resources :bulk_input
			resources :clear_db
			resources :display
		end
	end

	match '/finance/expenses/whats/remap', to: 'finance/expenses/whats#remap', via: 'get', as: 'finance_expenses_whats_remap'
	match '/finance/expenses/whats/remapupdate', to: 'finance/expenses/whats#remapupdate', via: 'get', as: 'finance_expenses_whats_remapupdate'
	match '/finance/investments/accounts/close', to: 'finance/investments/accounts#close', via: 'get', as: 'finance_investments_accounts_close'
	match '/finance/investments/summary_types/showupdate', to: 'finance/investments/summary_types#showupdate', via: 'put', as: 'finance_investments_summary_types_showupdate'
	match '/finance/investments/rebalance/showupdate', to: 'finance/investments/rebalance#showupdate', via: 'get', as: 'finance_investments_rebalance_showupdate'
	match '/finance/investments/rebalance_types/showupdate', to: 'finance/investments/rebalance_types#showupdate', via: 'get', as: 'finance_investments_rebalance_types_showupdate'

	namespace :finance do
		namespace :expenses do
			resources :accountmaps
			resources :bank_input
			resources :categories
			resources :donations
			resources :items
			resources :rent
			resources :rentalcosts
			resources :runningbudget
			resources :taxes
			resources :transfers
			resources :unused
			resources :yearbudget
			resources :what_maps
			resources :whats
		end
		namespace :investments do
			resources :accounts
			resources :charts
			resources :investments
			resources :rebalance
			resources :rebalance_types
			resources :summary
			resources :summary_types
		end
		namespace :payments do
			resources :current
			resources :transfers
			resources :cds
			resources :bills
		end
		namespace :admin do
			resources :exports
			resources :import
		end
	end


end
