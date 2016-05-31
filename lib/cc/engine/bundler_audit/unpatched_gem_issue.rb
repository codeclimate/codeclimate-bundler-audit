module CC
  module Engine
    module BundlerAudit
      class UnpatchedGemIssue
        CHECK_NAME = "Insecure Dependency".freeze
        GEM_REGEX = /^\s*(?<name>\S+) \([\S.]+\)/
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
            check_name: CHECK_NAME,
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
            fingerprint: fingerprint,
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
          UnpatchedGemRemediation.new(gem.version, parsed_upgrade_versions).points
        end

        def parsed_upgrade_versions
          expanded = advisory.patched_versions.map do |requirement|
            requirement.to_s.split(",").map(&:strip)
          end

          expanded.flatten.map do |version|
            requirements = Gem::Requirement.parse(version)
            requirements.last
          end
        end

        def severity
          SEVERITIES.fetch(advisory.criticality, "normal")
        end

        def solution
          if advisory.patched_versions.any?
            "upgrade to #{advisory.patched_versions.join(', ')}"
          else
            "remove or disable this gem until a patch is available!"
          end
        end

        def identifier
          advisory.cve_id || advisory.osvdb
        end

        def fingerprint
          BundlerAudit.fingerprint_for(CHECK_NAME, gem, advisory.id)
        end
      end
    end
  end
end
