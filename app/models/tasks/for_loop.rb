module Tasks
	
	class ForLoop < RTBench::Task
		
		def self.content_for_liquid
			"{% for post in posts %}{{ post.title }}{% endfor %}"
		end
		
		def self.content_for_haml
<<-HAML
- for post in posts
  = post.title
HAML
		end
		
		def self.content_for_erb
      "<% for post in posts %><%= post.title %><% end %>"
		end
		
	end
	
end

BenchmarkRegistrar.register_task(Tasks::ForLoop)
