Rails.application.routes.draw do
  mount Docs::Engine => "/support"

  get '/', to: 'chapters#index', as: 'support'
end
