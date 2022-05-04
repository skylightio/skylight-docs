Rails.application.reloader.to_prepare do
  ApplicationController.instance_exec do
    before_action do
      prepend_view_path Skylight::Docs::Engine.root.join('spec/test_source')
    end
  end
end
