require './alyzer'

use Rack::ShowExceptions
use Rack::Static, urls: ["/public"], root: Dir.pwd

run App.new
