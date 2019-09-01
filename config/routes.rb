Rails.application.routes.draw do
  root to: 'images#index'
  # Path for tag search autocompletion
  resources :posts, controller: :images, only: [] do
    get :autocomplete_tag_name, on: :collection
  end

  get '/home' => 'images#index'
  get '/posts' => 'images#search'
  get '/artists' => 'images#artists'
  get '/genres' => 'images#genres'
  get '/mediums' => 'images#mediums'
  get '/models' => 'images#models'
  get '/characters' => 'images#characters'
  get '/posts/(:id)' => 'images#show', as: 'post'
  get '/latest' => 'images#latest'
  get '/random' => 'images#random_image'
  get '/random_tag' => 'images#random_tag'
  get '/random_posts' => 'images#random_images'
  get '/check' => 'images#check'

  post '/' => 'images#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
