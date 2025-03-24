# frozen_string_literal: true

require_relative 'lib/selenium_chrome_helper/version'

Gem::Specification.new do |spec|
  spec.name          = 'selenium_chrome_helper'
  spec.version       = SeleniumChromeHelper::VERSION
  spec.authors       = ['Gonzalo Robaina']
  spec.email         = ['gonzalor@gmail.com']

  spec.summary       = 'Downloads and installs Chrome for Testing for use with Selenium system specs.'
  spec.description   = 'Adds a rake task (`chrome:install`) to easily fetch a pinned version of Chrome and Chromedriver locally or in CI.'
  spec.homepage      = 'https://github.com/yourname/selenium_chrome_helper'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb', 'lib/**/*.rake']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'rubyzip', '>= 2.0'
end
