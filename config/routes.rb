Skylight::Docs::Engine.routes.draw do
  # When reorganizing or renaming source files, be sure to add the appropriate
  # redirects to this hash.
  redirects = {
    "billing" => "app-and-account-management",
    "feature-walkthrough" => "skylight-guides",
    "filing-bugs" => "contributing",
    "get-to-know-skylight" => "skylight-guides",
    "getting-set-up" => "advanced-setup",
    "grape" => "advanced-setup",
    "instrumentation" => "getting-more-from-skylight",
    "multiple-environments" => "advanced-setup",
    "problems/repeated-queries" => "performance-tips",
    "running-skylight" => "advanced-setup",
    "sinatra" => "advanced-setup",
    "app-management-and-billing" => "app-and-account-management"
  }

  redirects.each do |key, value|
    get "/#{key}", to: redirect { |_path_params, req| "#{req.script_name}/#{value}" }
  end

  resources :chapters, only: [:index, :show], path: '/'
end
