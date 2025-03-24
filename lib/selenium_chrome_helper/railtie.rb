# frozen_string_literal: true

require 'rails/railtie'
require 'capybara'
require 'selenium/webdriver'

module SeleniumChromeHelper
  CHROME_VERSION = ENV.fetch('SELENIUM_CHROME_VERSION', '134.0.6998.165')

  # This Railtie configures Capybara to use a specific version of Google Chrome for testing.
  # It registers two drivers: one for headless testing and one for non-headless testing.
  class Railtie < Rails::Railtie
    initializer 'selenium_chrome_helper.configure_capybara' do
      platform = determine_platform
      base_path = Rails.root.join('.chrome-for-testing', CHROME_VERSION)
      chrome_path = determine_chrome_path(base_path, platform)
      driver_path = base_path.join("chromedriver-#{platform}", 'chromedriver').to_s

      Capybara.register_driver :chrome_for_testing do |app|
        Selenium::WebDriver::Chrome::Service.driver_path = driver_path

        options = configure_browser_options(chrome_path)
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end

      Capybara.register_driver :chrome_for_testing do |app|
        Selenium::WebDriver::Chrome::Service.driver_path = driver_path

        options = configure_browser_options(chrome_path, headless: false)
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
    end

    private

    def determine_platform
      case RUBY_PLATFORM
      when /darwin/
        `uname -m`.strip == 'arm64' ? 'mac-arm64' : 'mac-x64'
      when /linux/
        'linux64'
      else
        raise "Unsupported platform: #{RUBY_PLATFORM}"
      end
    end

    def determine_chrome_path(base_path, platform)
      if platform.start_with?('mac')
        base_path.join("chrome-#{platform}", 'Google Chrome for Testing.app', 'Contents',
                       'MacOS', 'Google Chrome for Testing').to_s
      else
        base_path.join("chrome-#{platform}", 'chrome').to_s
      end
    end

    def configure_browser_options(chrome_path, headless: true)
      options = Selenium::WebDriver::Chrome::Options.new
      options.binary = chrome_path
      options.add_argument('--headless=new') if headless
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')
      options.add_argument('--window-size=1400,1400')
      options
    end
  end
end
