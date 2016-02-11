module CC
  module Engine
    module BundlerAudit
      class Result
        GEM_REGEX = /^\s*(?<name>\S+) \([\d.]+\)/.freeze
        SEVERITIES = {
          high: "critical",
          medium: "normal",
          low: "info",
        }.freeze

        extend Forwardable

        def initialize(result, gemfile_lock)
          @gem = result.gem
          @advisory = result.advisory
          @gemfile_lock = gemfile_lock
        end

        def to_issue
          {
            categories: ["Security"],
            check_name: "Insecure Dependency",
            content: {
              body: content_body
            },
            description: advisory.title,
            location: {
              path: "Gemfile.lock",
              lines: {
                begin: line_number,
                end: line_number
              }
            },
            remediation_points: remediation_points,
            severity: severity,
            type: "Issue",
          }
        end

        private

        attr_reader :advisory, :gem, :gemfile_lock

        def content_body
          [
            "**Advisory**: #{identifier}",
            "**Criticality**: #{advisory.criticality.capitalize}",
            "**URL**: #{advisory.url}",
            "**Solution**: #{solution}",
          ].join("\n\n")
        end

        def line_number
          @line_number ||= begin
             gemfile_lock.find_index do |line|
               (match = GEM_REGEX.match(line)) && match[:name] == gem.name
             end + 1
          end
        end

        def remediation_points
          Remediation.new(gem.version, advisory.patched_versions).points
        end

        def severity
          SEVERITIES[advisory.criticality]
        end

        def solution
          if advisory.patched_versions.any?
            "upgrade to #{advisory.patched_versions.join(', ')}"
          else
            "remove or disable this gem until a patch is available!"
          end
        end

        def identifier
          case
          when advisory.cve then "CVE-#{advisory.cve}"
          when advisory.osvdb then advisory.osvdb
          end
        end
      end
    end
  end
end
