class ErbTask < RTBench::Task

	def self.content_for_erb_handler
		"<%= \"test\" %>"
	end
	
end