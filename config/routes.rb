Skylight::Docs::Engine.routes.draw do
  resources :chapters, only: [:index, :show], path: '/'
end
