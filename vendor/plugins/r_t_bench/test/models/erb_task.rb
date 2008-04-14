class ErbTask < RTBench::Task

	def content_for_erb_handler
		"<%= \"test\" %>"
	end
	
end