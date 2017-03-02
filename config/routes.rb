Skylight::Docs::Engine.routes.draw do
  # When reorganizing or renaming source files, be sure to add the appropriate
  # redirects to this hash.
  redirects = {
    "billing" => "get-to-know-skylight",
    "feature-walkthrough" => "get-to-know-skylight",
    "filing-bugs" => "contributing",
    "grape" => "getting-set-up",
    "multiple-environments" => "getting-set-up",
    "problems/repeated-queries" => "performance-tips",
    "sinatra" => "getting-set-up"
  }

  redirects.each do |key, value|
    get "/#{key}", to: redirect { |_path_params, req| "#{req.script_name}/#{value}" }
  end

  resources :chapters, only: [:index, :show], path: '/'
end
