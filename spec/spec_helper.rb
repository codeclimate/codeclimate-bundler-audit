$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))

require "rspec"
require "fakefs/safe"

require "cc/engine/bundler_audit"
