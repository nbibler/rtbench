module RTBench
	
	##
	# Tasks and executes them.
	#
	class Handler
		
		##
		# Executes the given Task through the Handler.
		#
		def process(task, arguments = {})
			raise NotImplementedError
		end
		
	end
	
end