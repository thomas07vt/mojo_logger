$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RACK_ENV"] ||= 'test'
require 'mojo_logger'
require 'pry'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation

end

