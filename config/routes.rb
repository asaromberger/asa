Rails.application.routes.draw do
	# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

	# Defines the root path route ("/")
	# root "articles#index"

	root 'sessions#new'

	resources :sessions
	resources :users
	resources :roles

	namespace :health do
		# resources :health
	end

end
