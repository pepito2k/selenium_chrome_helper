# selenium_chrome_helper

📦 A lightweight gem that installs and configures a specific version of **Chrome for Testing** and its matching **Chromedriver** for use with Selenium/Capybara system specs in Ruby and Rails projects.

---

## 🚀 Why use `selenium_chrome_helper`?

Managing Chrome and Chromedriver manually often leads to:

- ❌ Mismatched versions between your browser and driver
- ❌ Flaky tests caused by unexpected Chrome updates
- ❌ CI failures due to different environments

This gem solves those problems by:

- ✅ Downloading a **known-good version** of Chrome for Testing + Chromedriver
- ✅ Ensuring **version compatibility** across development and CI
- ✅ Avoiding dependency on system-installed Chrome or the deprecated `webdrivers` gem
- ✅ Working seamlessly in **Docker**, **CI**, and local environments
- ✅ Giving you control and visibility over the browser version your tests depend on

---

## 🔧 Installation

Add this gem to your Rails app or test suite:

```ruby
# Gemfile
group :test do
  gem "selenium_chrome_helper", path: "path/to/local/gem" # or from RubyGems later
end
```

Run:

```bash
bundle install
```

---

## 📦 Usage

Use the rake task to install a specific Chrome for Testing version (default is `134.0.6998.165`):

```bash
bundle exec rake chrome:install
```

Or specify a version:

```bash
bundle exec rake chrome:install[123.0.6312.86]
```

This will download Chrome and Chromedriver into:

```
chrome-for-testing/<version>/
├── chrome-<platform>/
├── chromedriver-<platform>/
```

The gem will automatically register a `:chrome_for_testing` Capybara driver when used in a Rails app, using the `Rails.root` path and the platform-specific Chrome/Chromedriver for the current system.

To use it in your system specs, configure your tests like this:

```ruby
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :chrome_for_testing
  end
end
```

If you need a non-headless browser for debugging, you can use the `:chrome_for_testing_gui` driver:

```ruby
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :chrome_for_testing_gui
  end
end
```

Optionally, you can override the version by setting the `SELENIUM_CHROME_VERSION` environment variable:

```bash
SELENIUM_CHROME_VERSION=123.0.6312.86 bundle exec rspec
```

---

## ✅ CI Compatibility

Run the same task in CI (e.g., GitHub Actions, CircleCI):

```bash
bundle exec rake chrome:install
```

This ensures consistent testing with the exact same Chrome version as your local environment. No extra driver setup is needed — the gem registers the driver automatically via Railtie.

---

## 🛠 Contributing

Thank you for considering contributing! Here's how you can help:

### 📦 Set up the project

```bash
git clone https://github.com/yourname/selenium_chrome_helper.git
cd selenium_chrome_helper
bundle install
```

### ✅ Add Features or Fixes

- Create a new branch (`git checkout -b feature/your-feature`)
- Write specs and make your changes
- Run `bundle exec rake` to verify
- Open a pull request 🙌

### 🧪 Testing locally in a Rails app

You can test the gem locally by pointing your Rails app's `Gemfile` to your local version:

```ruby
gem "selenium_chrome_helper", path: "../selenium_chrome_helper"
```

Then run:

```bash
bundle exec rake chrome:install
```

---

## 📄 License

This project is MIT licensed. See `LICENSE` for details.

---

## 🙌 Credits

Created by pepito2k. Inspired by the need for stable, repeatable Selenium system testing across platforms.
