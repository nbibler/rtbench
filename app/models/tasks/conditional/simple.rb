module Tasks
	
	module Conditional
		
		class Simple < RTBench::Task
			
			def content_for_liquid
				"{% if 1 > 0 %}{{ post.title }}{% endif %}"
			end
			
			def content_for_erb
      	"<% if 1 > 0 %><%= post.title %><% end %>"
			end
			
			def content_for_haml
<<-HAML
- if 1 > 0
  = post.title
HAML
			end
			
		end
		
	end
	
end