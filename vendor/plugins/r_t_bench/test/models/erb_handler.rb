require 'ostruct'

class ErbHandler < RTBench::Handler
	
	def process(task, arguments = {})
		vars = OpenStruct.new arguments
		ERB.new(task.for(self)).result(vars.send(:binding))
	end
	
end