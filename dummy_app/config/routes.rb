Rails.application.routes.draw do
  mount Skylight::Docs::Engine => "/support"

  get '/', to: 'skylight/docs/chapters#index', as: 'support'
end
