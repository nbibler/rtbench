module Tasks
	
	##
	# Tests accessing object attributes.
	#
	class AttributeAccess < RTBench::Task
		
		def content_for_liquid
			"{{post.title}}"
		end
		
		def content_for_haml
			"= post.title"
		end
		
		def content_for_erb
			"<%= post.title %>"
		end
		
	end
	
end