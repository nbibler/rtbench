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
			should "raise a NotImplementedError" do
				assert_raise(RTBench::NotImplementedError) do
					@handler.process Object.new
				end
			end
		end
		
	end
	
	context "A defined RTBench::Handler" do
		
		setup do
			@handler	= ErbHandler.new
			@task			=	ErbTask.new
			@task.stubs(:content_for).with(@handler).returns("<%= \"test\" %>")
		end
		
		should "properly render the task" do
			@task.expects(:content_for).with(@handler).returns("<%= \"test\" %>")
			assert_equal "test", @handler.process(@task)
		end
		
	end
	
end
