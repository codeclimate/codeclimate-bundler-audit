module CC
  module Engine
    module BundlerAudit
      class UnpatchedGemIssue
        GEM_REGEX = /^\s*(?<name>\S+) \([\d.]+\)/
        SEVERITIES = {
          high: "critical",
          medium: "normal",
          low: "info",
        }.freeze

        def initialize(result, gemfile_lock_lines)
          @gem = result.gem
          @advisory = result.advisory
          @gemfile_lock_lines = gemfile_lock_lines
        end

        def to_json(*a)
          {
            categories: %w[Security],
            check_name: "Insecure Dependency",
            content: {
              body: content_body,
            },
            description: advisory.title,
            location: {
              path: "Gemfile.lock",
              lines: {
                begin: line_number,
                end: line_number,
              },
            },
            remediation_points: remediation_points,
            severity: severity,
            type: "Issue",
          }.to_json(a)
        end

        private

        attr_reader :advisory, :gem, :gemfile_lock_lines

        def content_body
          lines = ["**Advisory**: #{identifier}"]
          lines << "**Criticality**: #{advisory.criticality.capitalize}" if advisory.criticality
          lines << "**URL**: #{advisory.url}"
          lines << "**Solution**: #{solution}"

          lines.join("\n\n")
        end

        def line_number
          @line_number ||= begin
            gemfile_lock_lines.find_index do |line|
              (match = GEM_REGEX.match(line)) && match[:name] == gem.name
            end + 1
          end
        end

        def remediation_points
          patched_versions = advisory.patched_versions.map do |gem_requirement|
            requirements = Gem::Requirement.parse(gem_requirement)
            requirements.last
          end

          UnpatchedGemRemediation.new(gem.version, patched_versions).points
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
