module Handlers
  
  class Haml < RTBench::Handler
    
    def self.execute(task, arguments = {})
      ::Haml::Engine.new(task.for(self)).render(Object.new, arguments)
    end
    
  end
  
end

RTBench::Registrar.register_handler Handlers::Haml
