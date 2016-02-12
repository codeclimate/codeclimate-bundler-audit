require "bundler/audit/scanner"
require "json"
require "versionomy"

require "cc/engine/bundler_audit/analyzer"
require "cc/engine/bundler_audit/insecure_source_issue"
require "cc/engine/bundler_audit/unpatched_gem_issue"
require "cc/engine/bundler_audit/unpatched_gem_remediation"

module CC
  module Engine
    module BundlerAudit
    end
  end
end

# Patch Bundler::Audit::Scanner to prevent network access during insecure
# source checks

Bundler::Audit::Scanner.module_eval do
  def internal_host?(_uri)
    false
  end
end
