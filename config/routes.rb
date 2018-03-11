Rails.application.routes.draw do
  Dir[Rails.root.join("config/routes/*.rb")].each{|r| load(r)}
end
