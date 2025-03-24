require "selenium_chrome_helper/version"

# Auto-load rake tasks when included in a Rails app or via `require`
if defined?(Rake)
  load File.expand_path("tasks/install.rake", __dir__)
end
