require "tmpdir"

module CC
  module Engine
    module BundlerAudit
      class Analyzer
        GemfileLockNotFound = Class.new(StandardError)
        DEFAULT_CONFIG_PATH = "/config.json".freeze
        GEMFILE = "Gemfile".freeze
        GEMFILE_LOCK = "Gemfile.lock".freeze

        def initialize(directory:, engine_config_path: DEFAULT_CONFIG_PATH, stdout: STDOUT, stderr: STDERR)
          @directory = directory
          @engine_config_path = engine_config_path
          @stdout = stdout
          @stderr = stderr
        end

        def run
          raise(GemfileLockNotFound, "No Gemfile.lock found.") unless gemfile_lock_exists?
          return unless gemfile_lock_in_include_paths?

          Dir.mktmpdir do |dir|
            FileUtils.cp(gemfile_lock_path, File.join(dir, GEMFILE_LOCK))
            FileUtils.cp(gemfile_path, File.join(dir, GEMFILE))

            Dir.chdir(dir) do
              Bundler::Audit::Scanner.new.scan do |vulnerability|
                if (issue = issue_for_vulerability(vulnerability))
                  stdout.print("#{issue.to_json}\0")
                else
                  stderr.print("Unsupported vulnerability: #{vulnerability.class.name}")
                end
              end
            end
          end
        end

        private

        attr_reader :directory, :engine_config_path, :stdout, :stderr

        def issue_for_vulerability(vulnerability)
          case vulnerability
          when Bundler::Audit::Scanner::UnpatchedGem
            UnpatchedGemIssue.new(vulnerability, gemfile_lock_relative_path, gemfile_lock_lines)
          when Bundler::Audit::Scanner::InsecureSource
            InsecureSourceIssue.new(vulnerability, gemfile_lock_relative_path, gemfile_lock_lines)
          end
        end

        def gemfile_lock_lines
          # N.B. this runs within the temporary directory, where the lock file
          # has been moved to ./Gemfile.lock so the scan will work.
          @gemfile_lock_lines ||= File.open(GEMFILE_LOCK).each_line.to_a
        end

        def gemfile_lock_exists?
          File.exist?(gemfile_lock_path)
        end

        def gemfile_lock_in_include_paths?
          include_paths = engine_config.fetch("include_paths", ["./"])
          include_paths.include?("./") || include_paths.include?(gemfile_lock_relative_path)
        end

        def engine_config
          @engine_config ||=
            if File.exist?(engine_config_path)
              JSON.parse(File.read(engine_config_path))
            else
              {}
            end
        end

        def gemfile_lock_path
          File.join(directory, gemfile_lock_relative_path)
        end

        def gemfile_lock_relative_path
          engine_config.fetch("config", {}).fetch("path", GEMFILE_LOCK)
        end

        def gemfile_path
          File.join(directory, gemfile_relative_path)
        end

        def gemfile_relative_path
          gemfile_lock_relative_path.sub(/\.lock$/, "")
        end
      end
    end
  end
end
