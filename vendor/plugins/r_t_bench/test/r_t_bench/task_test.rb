require File.dirname(__FILE__) + '/../test_helper'

class RTBench::TaskTest < Test::Unit::TestCase
	
	context "A generic RTBench::Task" do
		
		setup do
			@task = RTBench::Task
		end
		
		should "respond to 'for'" do
			assert_respond_to @task, :for
		end
		
		context ".for with a Handler with no content_for" do
			should "be raise a ContentForHandlerNotImplementedError" do
				assert_raise(RTBench::ContentForHandlerNotImplementedError) do
					@task.for(RTBench::Handler.new)
				end
				assert_kind_of RTBench::NotImplementedError, RTBench::ContentForHandlerNotImplementedError.new
			end
		end
		
		context ".for with a non-Handler" do
			should "raise an ArgumentError" do
				assert_raise(RTBench::ArgumentError) { @task.for Object.new }
			end
		end
		
	end
	
end
