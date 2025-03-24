# frozen_string_literal: true

require 'fileutils'
require 'open-uri'
require 'json'
require 'zip'

# rubocop:disable Metrics/BlockLength, Security/Open
namespace :chrome do
  desc 'Download and extract a known good version of Chrome for Testing'
  task :install, [:version] do |_, args|
    version = args[:version] || '134.0.6998.165'
    api_url = 'https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json'
    install_base = File.expand_path(".chrome-for-testing/#{version}", Dir.pwd)

    platform = case RUBY_PLATFORM
               when /darwin/
                 `uname -m`.strip == 'arm64' ? 'mac-arm64' : 'mac-x64'
               when /linux/
                 'linux64'
               else
                 raise "Unsupported platform: #{RUBY_PLATFORM}"
               end

    puts "➡️  Platform: #{platform}"
    puts "📡 Fetching metadata for Chrome version #{version}..."

    json = URI.open(api_url).read
    data = JSON.parse(json)

    version_info = data['versions'].find { |v| v['version'] == version }

    abort "❌ Version #{version} not found in known-good list." unless version_info

    chrome_url = version_info.dig('downloads', 'chrome')&.find { |d| d['platform'] == platform }&.dig('url')
    driver_url = version_info.dig('downloads', 'chromedriver')&.find { |d| d['platform'] == platform }&.dig('url')

    unless chrome_url && driver_url
      abort "❌ No matching downloads found for platform #{platform} and version #{version}"
    end

    puts "⬇️  Chrome URL: #{chrome_url}"
    puts "⬇️  Chromedriver URL: #{driver_url}"

    FileUtils.mkdir_p(install_base)

    download_and_unzip(chrome_url, File.join(install_base, 'chrome.zip'), install_base)
    download_and_unzip(driver_url, File.join(install_base, 'chromedriver.zip'), install_base)

    puts "✅ Chrome and Chromedriver installed to #{install_base}"
  end

  def download_and_unzip(url, zip_path, extract_to)
    download(url, zip_path)
    unzip(zip_path, extract_to)

    File.delete(zip_path)
  end

  def download(url, dest)
    URI.open(url) do |remote_file|
      File.open(dest, 'wb') { |file| file.write(remote_file.read) }
    end
  end

  def unzip(zip_path, extract_to)
    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.symlink? # silently skip symlinks

        entry_path = File.join(extract_to, entry.name)
        FileUtils.mkdir_p(File.dirname(entry_path))
        zip_file.extract(entry, entry_path) unless File.exist?(entry_path)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength, Security/Open
