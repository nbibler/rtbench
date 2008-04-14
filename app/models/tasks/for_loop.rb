module Tasks
	
	class ForLoop < RTBench::Task
		
		def content_for_liquid
			"{% for post in posts %}{{ post.title }}{% endfor %}"
		end
		
		def content_for_haml
<<-HAML
- for post in posts
  = post.title
HAML
		end
		
		def content_for_erb
      "<% for post in posts %><%= post.title %><% end %>"
		end
		
	end
	
end