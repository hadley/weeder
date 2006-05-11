#! /usr/bin/env ruby

$: << "/Users/hadley/documents/weaver/"
require 'optparse'
require 'pathname'
require 'builder'

clean = false
opts = OptionParser.new do |opts|
	opts.banner = "Usage: weeder [options] path of package"
	opts.on("-h", "--help",  "This help page") { puts opts.to_s}
end

args = opts.parse(ARGV)
if args.length != 1
	opts.warn "Please specify one file to process"
	puts opts.to_s
	exit
end

build_package(args[0])