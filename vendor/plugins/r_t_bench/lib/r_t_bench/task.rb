module RTBench
	
	##
	# A job to be performed by a Handler.  Each Task is handed to all registered
	# Handlers although they may not necessarily process them.
	#
	# The main body of the task to be executed is contained 
	#
	# To have a Task processed by a specific Handler, the task should
	# These should be written to be 
	# executed across multiple handlers.
	#
	class Task
		
		##
		# Public accessor for calling your custom (and hopefully private)
		# content_for method.  This method performs sanity checks on the input
		# given, making sure it is a valid Handler object, prior to handing it
		# to content_for.
		#
		def self.for(handler)
			raise ArgumentError unless handler.kind_of?(Handler)
			self.send("content_for_#{handler.class.to_s.split('::').last.underscore}")
		end
		
		
		##
		# Returns +nil+ if the requested method is an undefined content_for_XXXX
		# method.
		#
		def self.method_missing(method, *args)
			if method =~ /\Acontent_for_/
				return
			end
		end
		
	end
	
end