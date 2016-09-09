require 'rake/version_task'
Rake::VersionTask.new do |task|
  task.with_git_tag = true
end

desc "run pry console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  require 'pry'
  ARGV.clear
  exec "pry -r ./presence.rb"
end
