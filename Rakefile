require 'zlib'
require 'digest/md5'
require_relative 'lib/aws'

def run(*args)
  old = ENV['RUBYOPT']

  begin
    ENV['RUBYOPT'] = '-rbundler/setup'
    sh "ruby -S #{args.join(' ')}"
  ensure
    ENV['RUBYOPT'] = old
  end
end

def compress(str)
  output = StringIO.new
  gz = Zlib::GzipWriter.new(output)
  gz.write(str)
  gz.close
  output.string
end

def exts_regexp(exts)
  %r[(?:#{exts.map { |e| Regexp.escape(e) }.join("|")})$]
end

HASHED_EXTS   = %w( .jpg .jpeg .png .gif .js .css .eot .ttf .woff )
HASHED_FILE   = exts_regexp(HASHED_EXTS)
GZIPPED_EXTS  = %w( .js .css .html .htm )
GZIPPED_FILES = exts_regexp(GZIPPED_EXTS)

# Map out the content types
CONTENT_TYPES = {
  '.html' => "text/html",
  '.css'  => "text/css",
  '.js'   => "application/javascript",
  '.ico'  => "image/x-icon",
  '.png'  => "image/png",
  '.jpg'  => "image/jpeg",
  '.jpeg' => "image/jpeg",
  '.gif'  => "image/gif",
  '.eot'  => "application/vnd.ms-fontobject",
  '.woff' => "application/font-woff",
  '.otf'  => "application/octet-stream",
  '.ttf'  => "application/octet-stream",
  '.svg'  => "image/svg+xml",
  '.json' => "application/json"
}

desc "Deploy the docs"
task :deploy => :build do
  require 'fog'

  begin
    creds = Docs::AWS.credentials
    bucket = Docs::AWS.bucket
  rescue Docs::AWS::Error => e
    abort "Unable to get AWS configuration: #{e.message}"
  end

  conn = Fog::Storage.new(creds.merge(provider: 'AWS'))
  dir  = conn.directories.get(bucket)

  base = File.expand_path('../build', __FILE__)

  Dir["#{base}/**/*"].each do |file|
    next if File.directory?(file)
    next if /\.gz$/ =~ file # Skip gz files

    opts = {}
    gzip = false

    relative = file.sub("#{base}/", "")
    body = File.read(file)

    if GZIPPED_FILES =~ file
      gzip = true
      body = compress(body)
    end

    etag = Digest::MD5.hexdigest(body)

    if HASHED_FILE =~ file
      cache = "max-age=31556926"
    else
      cache = "max-age=600"
    end

    puts " * #{relative}"

    # S3 options
    opts[:key]              = relative
    opts[:body]             = body
    opts[:public]           = true
    opts[:etag]             = etag
    opts[:cache_control]    = cache
    opts[:content_encoding] = 'gzip' if gzip

    if content_type = CONTENT_TYPES[File.extname(file)]
      opts[:content_type] = content_type
    end

    # Upload that shiiiit
    dir.files.create(opts)
  end

  run 'middleman s3_redirect'
end

desc "Build the docs"
task :build do
  run 'middleman build'
end

desc "Preview the docs"
task :preview do
  run 'middleman'
end

task default: :preview
