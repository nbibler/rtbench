module Tasks
	
	class Filter < RTBench::Task
		
		def self.content_for_liquid
			"{{ time | date: '%B %d, %Y %H:%M:%S' }}"
		end
		
		def self.content_for_erb
    	"<%= time.strftime(\"%B %d, %Y %H:%M:%S\") %>"
		end
		
		def self.content_for_haml
			"= time.strftime(\"%B %d, %Y %H:%M:%S\")"
		end
		
	end
	
end

BenchmarkRegistrar.register_task(Tasks::Filter)
