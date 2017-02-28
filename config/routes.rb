Skylight::Docs::Engine.routes.draw do
  # When reorganizing or renaming source files, be sure to add the appropriate
  # redirects to this hash.
  redirects = {
    "billing" => "app-management-and-billing",
    "feature-walkthrough" => "skylight-guides",
    "filing-bugs" => "contributing",
    "get-to-know-skylight" => "skylight-guides",
    "grape" => "getting-set-up",
    "instrumentation" => "getting-more-from-skylight",
    "multiple-environments" => "getting-set-up",
    "performance-tips" => "skylight-guides",
    "problems/repeated-queries" => "skylight-guides",
    "running-skylight" => "getting-set-up",
    "sinatra" => "getting-set-up"
  }

  redirects.each do |key, value|
    get "/#{key}", to: redirect { |_path_params, req| "#{req.script_name}/#{value}" }
  end

  resources :chapters, only: [:index, :show], path: '/'
end
