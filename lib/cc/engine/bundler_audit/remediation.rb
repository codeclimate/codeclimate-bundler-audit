module CC
  module Engine
    module BundlerAudit
      class Remediation
        MAJOR_UPGRADE_POINTS = 50_000_000
        MINOR_UPGRADE_POINTS = 5_000_000
        PATCH_UPGRADE_POINTS = 500_000
        UNPATCHED_VERSION_POINTS = 500_000_000


        def initialize(gem_version, patched_versions)
          @gem_version = gem_version
          @patched_versions = patched_versions
        end

        def points
          if upgrade_versions.any?
            upgrade_versions.map do |upgrade_version|
              case
              when current_version.major != upgrade_version.major
                MAJOR_UPGRADE_POINTS
              when current_version.minor != upgrade_version.minor
                MINOR_UPGRADE_POINTS
              when current_version.tiny != upgrade_version.tiny
                PATCH_UPGRADE_POINTS
              end
            end.min
          else
            UNPATCHED_VERSION_POINTS
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
