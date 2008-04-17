require 'benchmark'
require 'logger'
require 'inflector'
require 'r_t_bench/identifiable'

Dir.glob(File.join(File.dirname(__FILE__), 'r_t_bench/**/*.rb')) do |f|
  require f.gsub!(/(.\/lib\/|\.rb)/i, '')
end

module RTBench
  LOG               = Logger.new(File.join(LOG_PATH, "rtbench.log"))
  LOG.formatter     = RTBench::Formatter.new
  ENGINE_BASE_PATH  = File.join(APP_ROOT, 'engines')
  SUITE_PATH        = File.join(APP_ROOT, 'suite')
  TEST_OBJECT_PATH  = File.join(SUITE_PATH, 'test_objects')
  
  
  class Error < ::RuntimeError; end
  class ArgumentError < Error; end
  class NotImplementedError < Error; end
  class ContentForHandlerNotImplementedError < NotImplementedError; end
  class EmptyTaskFileFoundError < Error; end
  
  
  ##
  # Loads the CURRENT template engines into the application.
  #
  def self.load_template_engines
    LOG.info "Loading template engines"
    Dir.glob(File.join(ENGINE_BASE_PATH, "**/current/lib/*.rb")) do |file|
      $LOAD_PATH << File.dirname(file) unless $LOAD_PATH.include?(File.dirname(file))
      require File.basename(file, '.rb')
    end
  end
  
  def self.load_test_objects
    LOG.info "Loading test objects"
    Dir.glob(File.join(TEST_OBJECT_PATH, '**/*.rb')) do |file|
      require file
    end
  end
  
  ##
  # Loads the test suite files.
  #
  def self.load_suite
    LOG.info "Loading test suite files"
    Dir.glob(File.join(SUITE_PATH, '{handlers,tasks}/**/*.rb')).each do |file|
      require file
    end
  end
  
  def self.run_suite(message = "Running test suite...")
    LOG.info "Running test suite"
    puts message
    Benchmark.bmbm do |results|
      Registrar.tasks.each do |task|
        Registrar.handlers.each do |handler|
          if task.for?(handler)
            if task.uses_object_pool?
              POOL_SIZES.each do |pool_size|
                arguments = test_arguments(pool_size)
                results.report("#{task.identifier.to_s.titleize} (#{handler.identifier.to_s.titleize}, #{pool_size})") { TEST_RUNS.times { handler.execute(task, arguments) } }
              end
            else
              arguments = test_arguments
              results.report("#{task.identifier.to_s.titleize} (#{handler.identifier.to_s.titleize})") { TEST_RUNS.times { handler.execute(task, arguments) } }
            end
          end
        end
      end
    end
    LOG.info "Test suite complete"
  end
  
  
  private
  
  def self.test_arguments(pool_size = 0)
    {
      "time"        => Time.now,
      "single_item" => TestObjects::Item.new,
      "item_pool"   => TestObjects::Item.collection_of(pool_size)
    }
  end
  
end