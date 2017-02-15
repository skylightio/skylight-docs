module Skylight
  module Docs
    VERSION = '0.1.0'

    Dir.chdir(__dir__) do
      REVISION = `git rev-parse HEAD`
    end
  end
end
