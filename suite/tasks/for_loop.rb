module Tasks
  
  class ForLoop < RTBench::Task
    def self.uses_object_pool?; true; end
  end
  
end

RTBench::Registrar.register_task Tasks::ForLoop
