module RTBench
	
	##
	# A job to be performed by a Handler.  Each Task is handed to all registered
	# Handlers although they may not necessarily process them.
	#
	# The main body of the Task to be executed will likely be unique to each
	# Handler and this framework easily allows for that. 
	#
	# Handlers will execute the +for+ method, passing themselves in as a 
	# parameter.  The +for+ method will validate the input, and then execute
	# the method which will generate the content specific to the given Handler
	# type.
	#
	# === content_for_XXXX tags
	#
	# To implement a Task for a specific Handler, you must create a 
	# +content_for_XXXX+ method.  This method takes no parameters, but instead
	# should be named appropriately for the desired Handler class.  The naming
	# convention is that XXXX represents the underscored version of the base
	# class name, for example:
	#
	#    class MyHandlers::Haml < RTBench::Handler
	#      ...
	#    end
	#    
	#    class MyTask < RTBench::Task
	#      
	#      # Returned when MyHandlers::Haml processes this task
	#      def content_for_haml
	#        "%h2= Time.now.to_s"
	#      end
	#      
	#      # Returned when MyHandlers::Erb processes this task
	#      def content_for_erb
	#        "<h2><%= Time.now.to_s %></h2>"
	#      end
	#      
	#    end
	#
	# If a Handler is passed and no appropriate content_for method is found, 
	# an RTBench::ContentForNotImplementedError will be raised.
	#
	#
	class Task
		
		##
		# Public accessor for calling your custom (and hopefully private)
		# content_for method.  This method performs sanity checks on the input
		# given, making sure it is a valid Handler object, prior to handing it
		# to content_for.
		#
		# In nearly all cases, this method should not be overridden.
		#
		def self.for(handler)
			raise ArgumentError unless handler.kind_of?(Handler)
			self.send("content_for_#{handler.class.to_s.split('::').last.underscore}")
		end
		
		
		##
		# Raises an RTBench::ContentForNotImplementedError if the requested 
		# method is an undefined content_for_XXXX method.
		#
		def self.method_missing(method, *args)
			if method.to_s =~ /\Acontent_for_/
				raise ContentForHandlerNotImplementedError, "#{method} not found"
			end
			
			super(method, args)
		end
		
	end
	
end