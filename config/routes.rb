Rails.application.routes.draw do
	# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

	# Defines the root path route ("/")
	# root "articles#index"

	root 'sessions#new'

	resources :sessions
	resources :users
	resources :roles
	resources :schema
	resources :data_checker
	resources :password_resets

	namespace :health do
		resources :data
		resources :import
		resources :stats
		resources :plots
	end

	namespace :bridge do
		resources :players
		resources :scores
		resources :import
	end

	namespace :music do
		resources :sync
		resources :albums
		resources :artists
		resources :genres
		resources :searches
		resources :playlists
		resources :play
	end

	namespace :genealogy do
		resources :individuals
		resources :information
	end

	match '/bridge/score/date', to: 'bridge/scores#date', via: 'get', as: 'bridge_score_date'
	match '/bridge/score/player', to: 'bridge/scores#player', via: 'get', as: 'bridge_score_player'
	match '//bridgescore/players_export', to: 'bridge/scores#players_export', via: 'get', as: 'bridge_score_players_export'
	match '/bridge/score/scores_export', to: 'bridge/scores#scores_export', via: 'get', as: 'bridge_score_scores_export'

end
