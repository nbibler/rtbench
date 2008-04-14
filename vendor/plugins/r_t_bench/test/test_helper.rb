$LOAD_PATH.unshift 'lib/'

require 'rubygems'
require 'multi_rails_init'
require 'action_controller/test_process'
require 'test/unit'
require 'r_t_bench'
require 'shoulda'
require 'mocha'

begin
	require 'redgreen'
rescue LoadError
end

RAILS_ROOT	= '.'			unless defined? RAILS_ROOT
RAILS_ENV		= 'test'	unless defined? RAILS_ENV

ActiveRecord::Base.establish_connection({
	:adapter	=> "sqlite3", 
	:dbfile		=> ":memory:"
})
ActiveRecord::Base.logger = Logger.new(STDOUT)

##
# Load the database schema.
#
load File.dirname(__FILE__) + "/db/schema.rb"

##
# Load the test models.
#
Dir.glob(File.join(File.dirname(__FILE__) + "/models/*")).each do |file|
	require file
end
