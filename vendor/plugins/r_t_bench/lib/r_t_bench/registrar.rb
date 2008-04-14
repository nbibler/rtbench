module RTBench
	
	##
	# Maintains collections of RTBench::Tasks and RTBench::Handlers.
	#
	class Registrar
		
		@@tasks			= []
		@@handlers	= []
		cattr_reader :tasks, :handlers
		
		##
		# Registers a new Task with the registrar.
		#
		def self.register_task(task)
			raise ArgumentError unless task.kind_of?(Class) && task.ancestors.include?(Task)
			@@tasks << task unless @@tasks.include?(task)
		end

		##
		# Registers a new Handler with the registrar.
		#
		def self.register_handler(handler)
			raise ArgumentError unless handler.kind_of?(Class) && handler.ancestors.include?(Handler)
			@@handlers << handler unless @@handlers.include?(handler)
		end
		
	end
	
end