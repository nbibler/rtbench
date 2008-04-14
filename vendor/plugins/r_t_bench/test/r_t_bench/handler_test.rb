require File.dirname(__FILE__) + '/../test_helper'

class RTBench::HandlerTest < Test::Unit::TestCase

	context "An generic RTBench::Handler" do
		
		setup do
			@handler = RTBench::Handler.new
		end
		
		should "respond to process" do
			assert_respond_to @handler, :process
		end
		
		context ".process" do
			should "raise a ProcessNotImplementedError" do
				assert_raise(RTBench::ProcessNotImplementedError) do
					@handler.process Object.new
				end
				assert_kind_of RTBench::NotImplementedError, RTBench::ProcessNotImplementedError.new
			end
		end
		
	end
	
	context "A defined RTBench::Handler" do
		
		setup do
			@handler	= ErbHandler.new
			@task			=	ErbTask
		end
		
		should "properly render the task" do
			assert_equal "test", @handler.process(@task)
		end
		
	end
	
end
