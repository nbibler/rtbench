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
		def for(handler)
			raise ArgumentError unless handler.kind_of?(Handler)
			self.send("content_for_#{handler.class.to_s.underscore}")
		end
		
		
		##
		# Returns +nil+ if the requested method is an undefined content_for_XXXX
		# method.
		#
		def method_missing(method, *args)
			if method =~ /\Acontent_for_/
				return
			end
		end
		
		
		private
		
		
		##
		# This should be overridden by your specific task.
		#
		# This method should return content specific to the Handler processing it.
		# For example, if you were testing template engines for basic processing 
		# time, you might do the following:
		#
		#    my_task.for(my_erb_handler) #=> "<%= \"Hello!\" %>"
		#    my_task.for(my_haml_handler) #=> "= \"Hello!\""
		#
		# The return value is specific to the type of Handler given.
		#
		def content_for(handler)
			raise NotImplementedError
		end
		
	end
	
end