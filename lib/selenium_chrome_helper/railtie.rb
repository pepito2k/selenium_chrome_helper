# frozen_string_literal: true

require 'rails/railtie'
require 'capybara'
require 'selenium/webdriver'

module SeleniumChromeHelper
  CHROME_VERSION = ENV.fetch('SELENIUM_CHROME_VERSION', '134.0.6998.165')

  # This Railtie configures Capybara to use a specific version of Google Chrome for testing.
  # It registers two drivers: one for headless testing and one for non-headless testing.
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.expand_path('../tasks/*.rake', __dir__)].each { |task| load task }
    end

    initializer 'selenium_chrome_helper.configure_capybara' do
      SeleniumChromeHelper::Railtie.register_driver(:chrome_for_testing, headless: true)
      SeleniumChromeHelper::Railtie.register_driver(:chrome_for_testing_gui, headless: false)
    end

    def self.base_path
      custom = ENV['CHROME_FOR_TESTING_PATH']
      Pathname.new(custom || Rails.root.join('.chrome-for-testing', CHROME_VERSION))
    end

    def self.platform
      case RUBY_PLATFORM
      when /darwin/
        `uname -m`.strip == 'arm64' ? 'mac-arm64' : 'mac-x64'
      when /linux/
        'linux64'
      else
        raise "Unsupported platform: #{RUBY_PLATFORM}"
      end
    end

    def self.chrome_path
      path = if platform.start_with?('mac')
               base_path.join("chrome-#{platform}", 'Google Chrome for Testing.app', 'Contents',
                              'MacOS', 'Google Chrome for Testing')
             else
               base_path.join("chrome-#{platform}", 'chrome')
             end
      warn "⚠️ Chrome binary not found at #{path}. Did you run `rake chrome:install`?" unless File.exist?(path)

      path.to_s
    end

    def self.driver_path
      path = base_path.join("chromedriver-#{platform}", 'chromedriver')
      warn "⚠️ Chromedriver not found at #{path}. Did you run `rake chrome:install`?" unless File.exist?(path)

      path.to_s
    end

    def self.configure_browser_options(headless: true)
      options = Selenium::WebDriver::Chrome::Options.new
      options.binary = chrome_path
      options.add_argument('--headless=new') if headless
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')
      options.add_argument('--window-size=1400,1400')
      options
    end

    def self.register_driver(name, headless:)
      Capybara.register_driver name do |app|
        Selenium::WebDriver::Chrome::Service.driver_path = driver_path
        options = configure_browser_options(headless: headless)
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
    end
  end
end
