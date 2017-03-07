module Skylight
  module Docs
    VERSION = '0.1.0'

    root_dir = File.basename(File.expand_path("../../../../", __FILE__))
    if root_dir =~ /-([0-9a-f]{6,})$/
      REVISION = $1
    else
      warn "Skylight::Docs REVISION cannot be determined, using VERSION instead."
      REVISION = VERSION
    end
  end
end
