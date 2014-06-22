RssReader::Application.routes.draw do

  devise_for :users, :controllers => {
                     :sessions => "sessions",
                     :registrations => "registrations"}
  resources :feeds

  root 'static_pages#index'
end
