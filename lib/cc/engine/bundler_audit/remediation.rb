module CC
  module Engine
    module BundlerAudit
      class Remediation
        def initialize(gem_version, patched_versions)
          @gem_version = gem_version
          @patched_versions = patched_versions
        end

        def points
          if upgrade_versions.any?
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

        private

        attr_reader :gem_version, :patched_versions

        def current_version
          @current_version ||= Versionomy.parse(gem_version.to_s)
        end

        def upgrade_versions
          @upgrade_versions ||= patched_versions.map do |gem_requirement|
            requirements = Gem::Requirement.parse(gem_requirement)
            unqualified_version = requirements.last

            Versionomy.parse(unqualified_version.to_s)
          end
        end
      end
    end
  end
end
