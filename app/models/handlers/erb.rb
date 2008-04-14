require 'ostruct'

module Handlers
	
	class Erb < ::RTBench::Handler
		
		def process(task, arguments = {})
			vars = ::OpenStruct.new arguments
			::ERB.new(task.for(self)).result(vars.send(:binding))
		end
		
	end
	
end

BenchmarkRegistrar.register_handler(Handlers::Erb)
