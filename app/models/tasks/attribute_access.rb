module Tasks
	
	##
	# Tests accessing object attributes.
	#
	class AttributeAccess < RTBench::Task
		
		def self.content_for_liquid
			"{{post.title}}"
		end
		
		def self.content_for_haml
			"= post.title"
		end
		
		def self.content_for_erb
			"<%= post.title %>"
		end
		
	end
	
end