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
	end

end
