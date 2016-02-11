require "forwardable"
require "json"
require "versionomy"

module CC
  module Engine
    class ResultDecorator
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

      def_delegators :gem, :name, :version
      def_delegators :advisory, :criticality, :title, :cve, :patched_versions, :url

      def content_body
        [
          "**Advisory**: #{identifier}",
          "**Criticality**: #{criticality.capitalize}",
          "**URL**: #{url}",
          "**Solution**: #{solution}",
        ].join("\n\n")
      end

      def line_number
        @line_number ||= begin
           gemfile_lock.find_index do |line|
             (match = GEM_REGEX.match(line)) && match[:name] == name
           end + 1
        end
      end

      def remediation_points
        if patched_versions.any?
          upgrade_versions.map do |upgrade_version|
            case
            when current_version.major != upgrade_version.major
              50_000_000
            when current_version.minor != upgrade_version.minor
              5_000_000
            when current_version.tiny != upgrade_version.tiny
              500_000
            end
          end.min
        else
          500_000_000
        end
      end

      def severity
        SEVERITIES[criticality]
      end

      def solution
        if patched_versions.any?
          "upgrade to #{patched_versions.join(', ')}"
        else
          "remove or disable this gem until a patch is available!"
        end
      end

      def identifier
        case
        when cve then "CVE-#{cve}"
        when osvdb then osvdb
        end
      end

      def current_version
        Versionomy.parse(version.to_s)
      end

      def upgrade_versions
        patched_versions.map do |gem_requirement|
          requirements = Gem::Requirement.parse(gem_requirement)
          unqualified_version = requirements.last

          Versionomy.parse(unqualified_version.to_s)
        end
      end
    end
  end
end
