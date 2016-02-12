module CC
  module Engine
    module BundlerAudit
      class Analyzer
        GemfileLockNotFound = Class.new(StandardError)

        def initialize(directory:, stdout: STDOUT, stderr: STDERR)
          @directory = directory
          @stdout = stdout
          @stderr = stderr
        end

        def run
          if gemfile_lock_exists?
            Dir.chdir(directory) do
              Bundler::Audit::Scanner.new.scan do |vulnerability|
                if issue = issue_for_vulerability(vulnerability)
                  stdout.print("#{issue.to_json}\0")
                else
                  stderr.print("Unsupported vulnerability: #{vulnerability.class.name}")
                end
              end
            end
          else
            raise GemfileLockNotFound, "No Gemfile.lock found."
          end
        end

        private

        attr_reader :directory, :stdout, :stderr

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

        def gemfile_lock_path
          File.join(directory, "Gemfile.lock")
        end
      end
    end
  end
end
