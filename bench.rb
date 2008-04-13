#!/usr/bin/env ruby
require 'config/environment'
require 'benchmark'

TESTS = 10_000

class Hash
  def to_binding(object = Object.new)
    object.instance_eval("def binding_for(#{keys.join(",")}) binding end")
    object.binding_for(*values)
  end
end

module Templates
  LIQUID, ERB, HAML = 0, 1, 2

  # Templates
  TEMPLATES = {
    
    :print => [
      "<h2>{{posts.first.title}}</h2>", 
      "<h2><%= posts.first.title %></h2>",
      "%h2= posts.first.title"
    ],
    
    :loop => [ 
      "{% for post in posts %}{{ post.title }}{% endfor %}",
      "<% for post in posts %><%= post.title %><% end %>",
<<-HAML
- for post in posts
  = post.title
HAML
    ],
    
    :filter => [
      "{{ time | date: '%B %d, %Y %H:%M:%S' }}",
      "<%= time.strftime(\"%B %d, %Y %H:%M:%S\") %>",
			"= time.strftime(\"%B %d, %Y %H:%M:%S\")"
    ],
  
    :conditional => [
      "{% if 1 > 0 %}{{ post.title }}{% endif %}",
      "<% if 1 > 0 %><%= post.title %><% end %>",
<<-HAML
- if 1 > 0
  = post.title
HAML
    ],
  
    :complex_conditional => [
      "{% if 1 > 0 and 5 < 10 %}{{ post.title }}{% endif %}",
      "<% if 1 > 0 and 5 < 10 %><%= post.title %><% end %>",
<<-HAML
- if 1 > 0 and 5 < 10
  = post.title
HAML
    ]
    
  }

end

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
    vars = {
      "posts"   => Post.find(:all),
      "post"    => Post.find(:first),
      "time"    => Time.now
    }

    Benchmark.bmbm do |results|
      Templates::TEMPLATES.each_pair do |name, templates|
        results.report("Liquid:  #{name.to_s.titleize}")  { TESTS.times { Liquid::Template.parse(templates[Templates::LIQUID]).render(vars) } }
        results.report("HAML:    #{name.to_s.titleize}")  { TESTS.times { Haml::Engine.new(templates[Templates::ERB]).render(Object.new, vars) } }
        results.report("ERB:     #{name.to_s.titleize}")  { TESTS.times { ERB.new(templates[Templates::ERB]).result(vars.to_binding) } }
      end
    end
  end
  
end

TemplateTest.clear_posts
TemplateTest.create_posts
TemplateTest.run
TemplateTest.clear_posts