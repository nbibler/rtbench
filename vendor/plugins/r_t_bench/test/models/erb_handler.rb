class ErbHandler < RTBench::Handler
	
	def process(task, arguments = {})
		ERB.new(task.for(self)).result(arguments.to_binding)
	end
	
end