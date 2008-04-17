require 'yaml'

module RTBench
  
  class Task
    extend Identifiable
    
    TASK_FILE = "tasks.yml"
    
    ##
    # Returns Task content specific to the requested Handler.
    #
    # ===== Exceptions raised
    #
    # RTBench::ArgumentError:: The given handler is not an RTBench::Handler
    # RTBench::ContentForHandlerNotImplementedError:: The YAML task file for the Handler could not be found
    #
    def self.for(handler)
      validate handler
      find_task_for(handler) || raise(ContentForHandlerNotImplementedError, "Custom task content for #{handler} - #{self} could not be found")
    end
    
    ##
    # Returns +true+ if the Task has content for the given Handler.
    #
    # ===== Exceptions raised
    #
    # RTBench::ArgumentError:: The given handler is not an RTBench::Handler
    #
    def self.for?(handler)
      validate handler
      !find_task_for(handler).nil?
    rescue ContentForHandlerNotImplementedError => e
      false
    end

    ##
    # Dictates whether or not the task utilizes the object pool during 
    # testing.  This should be overridden to +true+ if your task requires
    # the pool (such as a looping task).
    # 
    def self.uses_object_pool?; false; end

    
    protected
    
    
    ##
    # Returns content specific to the handler requested.  If content specific
    # to the given Handler cannot be found, then +nil+ is returned.
    #
    def self.find_task_for(handler)
      handler_id              = handler.identifier
      @@content               ||= {}
      @@content[handler_id]   ||= load_yaml_content_for handler
      
      raise(EmptyTaskFileFoundError, "Empty #{TASK_FILE} for #{handler}") unless @@content[handler_id]
      @@content[handler_id][self.identifier.to_s]
    end

    ##
    # Loads the contents of the task.yml file for the given handler.
    #
    def self.load_yaml_content_for(handler)
      yaml_path = File.join RTBench::ENGINE_BASE_PATH, handler.identifier.to_s, TASK_FILE
      raise(ContentForHandlerNotImplementedError, "#{TASK_FILE} file not found at #{yaml_path}") unless File.exist?(yaml_path)
      YAML.load_file yaml_path
    end
    
    ##
    # Raises ArgumentError unless parameter is a derivative of 
    # RTBench::Handler
    #
    def self.validate(handler)
      raise(ArgumentError, "Handler expected") unless handler.kind_of?(Class) && handler.ancestors.include?(RTBench::Handler)
    end
    
  end
  
end