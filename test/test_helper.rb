ENV['RACK_ENV'] = 'test'

require "test/unit"
require "rack/test"
require "mocha"

%w[ lib ].each do |path|
  $:.unshift path unless $:.include?(path)
end
