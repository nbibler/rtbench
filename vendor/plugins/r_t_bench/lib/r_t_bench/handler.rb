module RTBench
	
	##
	# A Handler should be an object which encapsulates the process that you 
	# wish to benchmark.  Handlers take Tasks and +process+ them.  This 
	# processing time should be benchmarked from outside of the Handler class.
	#
	# === Process
	#
	# The process method should be overridden by your custom Handler class.
	# This is the method which will be handed each task and asked to perform
	# it.
	#
	# === Example
	#
	#   class Haml < RTBench::Handler
	#
	#     ##
	#     # Processes a given task, assuming that it will be a String to be
	#     # parsed by HAML.
	#     #
	#     def process(task, arguments = {})
	#       Haml::Engine.new(task.for(self)).render(Object.new, arguments)
	#     end
	#     
	#   end
	#
	class Handler
		
		##
		# Executes the given Task through the Handler.  This method should be
		# overridden by your custom Handler class.
		#
		def process(task, arguments = {})
			raise ProcessNotImplementedError, "process not defined in #{self.class}"
		end
		
	end
	
end