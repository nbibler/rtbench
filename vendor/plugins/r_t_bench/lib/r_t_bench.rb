require 'r_t_bench/handler'
require 'r_t_bench/task'

##
#
#
module RTBench
	
	class Error < RuntimeError; end
	class ArgumentError < Error; end
	class NotImplementedError < Error; end
	class ProcessNotImplementedError < NotImplementedError; end
	class ContentForHandlerNotImplementedError < NotImplementedError; end
	
end