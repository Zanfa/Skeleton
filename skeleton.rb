#!/usr/bin/env ruby
require 'yaml'
require 'pathname'
require 'fileutils'
require 'optparse'

template_name, target_path = ARGV

$flags = {}
OptionParser.new do |o|
  o.banner = "Usage: skeleton template path [options]"

  o.on('-d', '--dry-run', 'Do a dry run with no side effects, useful for testing new configuration') do |d|
    $flags[:dry] = d
  end
end.parse!

puts "Dry run, nothing will actually be created" if $flags[:dry]

# Set the default path to be current
target_path ||= Dir.pwd
# Prevent flags from screwing up target_path if it's not set
target_path = Dir.pwd if target_path.start_with? '-'
# Expand relative paths 
target_path = File.join(Dir.pwd, target_path) unless Pathname.new(target_path).absolute?

puts "Using template #{template_name} in #{target_path}"

def create_path(parent, path)
    puts "Creating path #{File.join(parent, path)}"
    FileUtils.mkpath File.join(parent, path) unless $flags[:dry]
end

def create_structure(root_path, structure)
  structure.each do |path|

    # Created nested paths
    if path.is_a? Hash
      create_structure(File.join(root_path, path.keys[0]), path.values[0])
      next
    end

    create_path(root_path, path)
  end
end

template = YAML.load_file(File.join(Dir.home, '.skeleton', "#{template_name}.yaml"))
create_structure target_path, template['structure']
