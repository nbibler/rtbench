module Handlers
	
	class Liquid < ::RTBench::Handler
		
		def process(task, arguments = {})
			::Liquid::Template.parse(task.for(self)).render(arguments)
		end
		
	end
	
end

BenchmarkRegistrar.register_handler(Handlers::Liquid)
