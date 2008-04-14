module Tasks
	
	module Conditional
		
		class Complex < RTBench::Task

			def self.content_for_liquid
				"{% if 1 > 0 and 5 < 10 %}{{ post.title }}{% endif %}"
			end
			
			def self.content_for_erb
      	"<% if 1 > 0 and 5 < 10 %><%= post.title %><% end %>"
			end
			
			def self.content_for_haml
<<-HAML
- if 1 > 0 and 5 < 10
  = post.title
HAML
			end
			
		end
		
	end
	
end