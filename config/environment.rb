RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.load_paths += [
    "#{RAILS_ROOT}/app/drops"
  ]

  config.action_controller.session = {
    :session_key => '_liquid_session',
    :secret      => 'cd5ca77724b9bfd6bb7de242994c1a65a89a3802a5c3391b051ce7c1161b1a69089e53577908f197101be8ce29402b9f53bfd055666a8e967e04bc255b56195e'
  }

end