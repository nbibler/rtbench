module Handlers
	
	class Haml < ::RTBench::Handler
		
		def process(task, arguments = {})
			::Haml::Engine.new(task.for(self)).render(Object.new, arguments)
		end
		
	end
	
end

BenchmarkRegistrar.register_handler(Handlers::Haml)
