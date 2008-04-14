#!/usr/bin/env ruby
require 'config/environment'
require 'benchmark'

TESTS 			= 100
HANDLERS 		= [
								Handlers::Erb, 
								Handlers::Haml, 
								Handlers::Liquid
							]
TASKS				=	[ 
								Tasks::AttributeAccess,
								Tasks::Filter,
								Tasks::ForLoop,
								Tasks::Conditional::Complex,
								Tasks::Conditional::Simple
							]

class TemplateTest
  
  def self.clear_posts
    Post.destroy_all
  end
  
  def self.create_posts(count = 100)
    count.times do
      returning Post.new do |post|
        post.title = "a" * rand(100)
        post.description = "b" * rand(250)
        post.save!
      end
    end
  end
  
  def self.run
		skipped = []
		
    vars = {
      "posts"   => Post.find(:all),
      "post"    => Post.find(:first),
      "time"    => Time.now
    }

    Benchmark.bmbm do |results|
      TASKS.each do |task|
				HANDLERS.each do |handler|
					results.report("#{task.to_s} (#{handler.to_s})") do
						begin
							TESTS.times { handler.new.process(task, vars) }
						rescue RTBench::ContentForHandlerNotImplementedError => e
							skipped << "#{task.to_s} (#{handler.to_s}) - Task content not found for handler"
						end
					end
				end
      end
    end

		report_skipped(skipped) unless skipped.empty?
  end

	private

	def self.report_skipped(skipped = [])
		skipped.uniq!
		puts ""
		puts "=== Tests Skipped ==="
		puts "* " << skipped.join("\n* ")
		puts ""
	end
  
end

TemplateTest.clear_posts
TemplateTest.create_posts
TemplateTest.run
TemplateTest.clear_posts