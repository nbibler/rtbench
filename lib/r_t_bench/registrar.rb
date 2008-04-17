module RTBench
  
  ##
  # Manages collections of RTBench::Task and RTBench::Handler objects.
  #
  class Registrar
    
    @@tasks, @@handlers = [], []
    
    ##
    # Register a new RTBench::Handler with the registrar.
    #
    def self.register_handler(handler)
      unless handler.kind_of?(Class) && handler.ancestors.include?(Handler)
        raise(ArgumentError, "Handler expected")
      end
      @@handlers << handler unless @@handlers.include?(handler)
    end
    
    ##
    # Register a new RTBench::Task with the registrar.
    #
    def self.register_task(task)
      unless task.kind_of?(Class) && task.ancestors.include?(Task)
        raise(ArgumentError, "Task expected")
      end
      @@tasks << task unless @@tasks.include?(task)
    end
    
    ##
    # Returns the collection of RTBench::Task objects as an Array.
    #
    def self.tasks; @@tasks; end
    
    ##
    # Returns the collection of RTBench::Handler objects as an Array.
    #
    def self.handlers; @@handlers; end
    
    private
    
    def initialize #:nodoc:
    end
    
  end
  
end