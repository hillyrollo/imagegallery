Rails.application.routes.draw do
  root to: 'images#index'
  get '/home' => 'images#index'
  get '/posts' => 'images#search'
  get '/artists' => 'images#artists'
  get '/genres' => 'images#genres'
  get '/characters' => 'images#characters'
  get '/posts/(:id)' => 'images#view', as: 'post'
  get '/latest' => 'images#latest'
  get '/random' => 'images#random_image'
  get '/random_tag' => 'images#random_tag'

  post '/' => 'images#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
