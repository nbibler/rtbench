require File.dirname(__FILE__) + '/../test_helper'

class RTBench::RegistrarTest < Test::Unit::TestCase
	
	context "A Registrar" do
		
		setup do
			@registrar = RTBench::Registrar
		end
		
		context "for Tasks" do
			
			should "accept a Task object" do
				@registrar.register_task(ErbTask)
			end
			
			should "raise an RTBench::ArgumentError for a non-task object" do
				assert_raise(RTBench::ArgumentError) do
					@registrar.register_task(Object.new)
				end
			end
			
		end
		
		context "for Handlers" do
			
			should "accept a Handler object" do
				@registrar.register_handler(ErbHandler)
			end
			
			should "raise an RTBench::ArgumentError for a non-Handler object" do
				assert_raise(RTBench::ArgumentError) do
					@registrar.register_handler(Object.new)
				end
			end
			
		end
		
	end
		
end
