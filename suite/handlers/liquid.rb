module Handlers
  
  class Liquid < RTBench::Handler
    
    def self.execute(task, arguments = {})
      ::Liquid::Template.parse(task.for(self)).render(arguments)
    end
    
  end
  
end

RTBench::Registrar.register_handler Handlers::Liquid
