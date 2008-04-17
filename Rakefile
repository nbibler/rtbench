require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'fileutils'
require 'lib/inflector'

namespace :rtbench do
  
  namespace :engine do
    
    desc "Sets up a new template engine directory (pass ENGINE=XXXX)"
    task :setup => [:build_directories, :unpack, :relink, :create_empty_tasks]
    
    task :build_directories do
      raise(ArgumentError, "Expected ENGINE=GEMNAME") unless ENV["ENGINE"]
      FileUtils.mkdir_p File.join(engine_directory(ENV["ENGINE"]), 'releases')
    end
    
    desc "Unpacks activeENGINE=GEMNAME gem into the releases directory"
    task :unpack do
      raise(ArgumentError, "Expected ENGINE=GEMNAME") unless ENV["ENGINE"]
      `cd #{engine_directory(ENV["ENGINE"])}/releases; gem unpack #{ENV["ENGINE"]}`
    end
    
    desc "Links the highest version for ENGINE=GEMNAME in releases as current"
    task :relink do
      raise(ArgumentError, "Expected ENGINE=GEMNAME") unless ENV["ENGINE"]

      engine                = engine_directory(ENV["ENGINE"])
      releases              = File.join(engine, 'releases')
      current               = File.join(engine, 'current')
      unpacked_directories  = Dir.entries(releases).select { |f| !(f =~ /\A(\.|\.\.)\Z/i) }.sort
      current_gem           = unpacked_directories.last
      raise(RuntimeError, "No directory found to link") unless current_gem
      
      FileUtils.rm_f current
      FileUtils.ln_s File.join(releases, current_gem), current
      puts "Linked #{current_gem} as current version for #{ENV["ENGINE"]}"
    end
    
    desc "Creates an empty tasks.yml file for ENGINE=GEMNAME"
    task :create_empty_tasks do
      raise(ArgumentError, "Expected ENGINE=GEMNAME") unless ENV["ENGINE"]

      engine_tasks = File.join(engine_directory(ENV["ENGINE"]), "tasks.yml")
      return if File.exists?(engine_tasks)
      File.open(engine_tasks, File::WRONLY | File::CREAT) do |tasks|
        tasks.write "#\n# Tasks for #{ENV["ENGINE"]}\n#\n"
      end
    end
    
    def engine_directory(engine)
      File.join(File.dirname(__FILE__), 'engines', ENV["ENGINE"].underscore)
    end
    
  end
  
end