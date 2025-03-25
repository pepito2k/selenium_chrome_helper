# frozen_string_literal: true

require 'fileutils'

namespace :chrome do
  desc 'Remove the .chrome-for-testing directory and all its contents'
  task :cleanup do
    chrome_dir = File.expand_path('.chrome-for-testing', Dir.pwd)

    unless Dir.exist?(chrome_dir)
      puts " ❌ Directory #{chrome_dir} does not exist."
      next
    end

    puts " ⚠️  This will permanently delete the directory: #{chrome_dir}"
    print ' Are you sure? (yes/no): '
    confirmation = $stdin.gets.strip.downcase

    if confirmation == 'yes'
      FileUtils.rm_rf(chrome_dir)
      puts " ✅ Directory #{chrome_dir} has been removed."
    else
      puts ' ❌ Operation canceled.'
    end
  end
end
