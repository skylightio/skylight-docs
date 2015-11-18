module Docs
  module AWS
    def self.credentials
      file = File.expand_path('~/.fog')
      unless File.exist?(file)
        puts "~/.fog missing"
        abort
      end

      creds = YAML.load_file(file)
      creds[:'skylight-docs'] ||
        creds['skylight-docs'] ||
        creds[:'tilde-parent'] ||
        creds['tilde-parent'] ||
        creds[:default] ||
        creds['default']
    end

    def self.bucket
      'skylight-docs'
    end
  end
end