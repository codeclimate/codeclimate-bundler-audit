module CC
  module Engine
    module BundlerAudit
      class Analyzer
        GemfileLockNotFound = Class.new(StandardError)
        DEFAULT_CONFIG_PATH = "/config.json".freeze

        def initialize(directory:, engine_config_path: DEFAULT_CONFIG_PATH, stdout: STDOUT, stderr: STDERR)
          @directory = directory
          @engine_config_path = engine_config_path
          @stdout = stdout
          @stderr = stderr
        end

        def run
          raise(GemfileLockNotFound, "No Gemfile.lock found.") unless gemfile_lock_exists?
          return unless gemfile_lock_in_include_paths?

          Dir.chdir(directory) do
            Bundler::Audit::Scanner.new.scan do |vulnerability|
              if (issue = issue_for_vulerability(vulnerability))
                stdout.print("#{issue.to_json}\0")
              else
                stderr.print("Unsupported vulnerability: #{vulnerability.class.name}")
              end
            end
          end
        end

        private

        attr_reader :directory, :engine_config_path, :stdout, :stderr

        def issue_for_vulerability(vulnerability)
          case vulnerability
          when Bundler::Audit::Scanner::UnpatchedGem
            UnpatchedGemIssue.new(vulnerability, gemfile_lock_lines)
          when Bundler::Audit::Scanner::InsecureSource
            InsecureSourceIssue.new(vulnerability, gemfile_lock_lines)
          end
        end

        def gemfile_lock_lines
          @gemfile_lock_lines ||= File.open(gemfile_lock_path).each_line.to_a
        end

        def gemfile_lock_exists?
          File.exist?(gemfile_lock_path)
        end

        def gemfile_lock_in_include_paths?
          include_paths = engine_config.fetch("include_paths", ["./"])
          include_paths.include?("./") || include_paths.include?("Gemfile.lock")
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
          File.join(directory, "Gemfile.lock")
        end
      end
    end
  end
end
