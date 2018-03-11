Rails.application.routes.draw do
  namespace :api do
    post '/login', to: "authentication#login"
    get '/logout', to: "authentication#logout"
  end
end
