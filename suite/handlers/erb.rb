require 'ostruct'
 
module Handlers
  
  class Erb < RTBench::Handler
    
    def self.execute(task, arguments = {})
      vars = ::OpenStruct.new arguments
      ::ERB.new(task.for(self)).result(vars.send(:binding))
    end
    
  end
  
end
 
RTBench::Registrar.register_handler Handlers::Erb