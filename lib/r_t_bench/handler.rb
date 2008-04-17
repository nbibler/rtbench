module RTBench
  
  class Handler
    extend Identifiable
    
    ##
    # Executes a given RTBench::Task.
    #
    def self.execute(task, arguments = {})
      raise NotImplementedError, "Handler.execute should be overridden by your custom handler"
    end
    
    ##
    # Override to true if the handler is cachable.
    #
    def self.cachable?; false; end
    
  end
  
end