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

	namespace :bridge do
		resources :import
		resources :players
		resources :scores
	end

	match '/bridge/score/date', to: 'bridge/scores#date', via: 'get', as: 'bridge_score_date'
	match '/bridge/score/player', to: 'bridge/scores#player', via: 'get', as: 'bridge_score_player'
	match '//bridgescore/players_export', to: 'bridge/scores#players_export', via: 'get', as: 'bridge_score_players_export'
	match '/bridge/score/scores_export', to: 'bridge/scores#scores_export', via: 'get', as: 'bridge_score_scores_export'

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

	namespace :finance do
		namespace :expenses do
			resources :accountmaps
			resources :categories
			resources :items
			resources :rent
			resources :rentalcosts
			resources :runningbudget
			resources :yearbudget
			resources :what_maps
			resources :whats
		end
		namespace :admin do
			resources :import
		end
	end

	match '/finance/expenses/whats/remap', to: 'finance/expenses/whats#remap', via: 'get', as: 'finance_expenses_whats_remap'

end
