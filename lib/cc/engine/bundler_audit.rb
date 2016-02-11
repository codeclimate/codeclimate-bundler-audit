require "json"
require "bundler/audit/scanner"
require_relative "./result_decorator"

module CC
  module Engine
    class BundlerAudit
      GemfileLockNotFound = Class.new(StandardError)

      def initialize(directory: , io: , engine_config: )
        @directory = directory
        @engine_config = engine_config
        @io = io
      end

      def run
        if gemfile_lock_exists?
          Dir.chdir(@directory) do
            Bundler::Audit::Scanner.new.scan do |result|
              gemfile_lock = File.open(gemfile_lock_path)
              decorated = ResultDecorator.new(result, gemfile_lock)
              issue = decorated.to_issue

              @io.print("#{issue.to_json}\0")
            end
          end
        else
          raise GemfileLockNotFound, "No Gemfile.lock found."
        end
      end

      private

      def gemfile_lock_exists?
        File.exist?(gemfile_lock_path)
      end

      def gemfile_lock_path
        File.join(@directory, "Gemfile.lock")
      end
    end
  end
end

