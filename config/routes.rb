Docs::Engine.routes.draw do
  root to: "chapters#index"

  get '/:chapter', to: 'chapters#show'
end
