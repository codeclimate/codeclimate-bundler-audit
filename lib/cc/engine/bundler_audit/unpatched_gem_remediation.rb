module CC
  module Engine
    module BundlerAudit
      class UnpatchedGemRemediation
        MAJOR_UPGRADE_POINTS = 50_000_000
        MINOR_UPGRADE_POINTS = 5_000_000
        TINY_UPGRADE_POINTS = 500_000
        MINIMUM_UPGRADE_POINTS = 50_000
        UNPATCHED_VERSION_POINTS = 500_000_000

        def initialize(gem_version, patched_versions)
          @gem_version = gem_version
          @patched_versions = patched_versions
        end

        def points
          if upgrade_versions.any?
            upgrade_versions.map { |version| calculate_points(version) }.min
          else
            UNPATCHED_VERSION_POINTS
          end
        end

        private

        attr_reader :gem_version, :patched_versions

        def calculate_points(upgrade_version)
          case
          when current_version.major != upgrade_version.major
            MAJOR_UPGRADE_POINTS
          when current_version.minor != upgrade_version.minor
            MINOR_UPGRADE_POINTS
          when current_version.tiny != upgrade_version.tiny
            TINY_UPGRADE_POINTS
          else
            MINIMUM_UPGRADE_POINTS
          end
        end

        def current_version
          @current_version ||= parse_version(gem_version.to_s)
        end

        def upgrade_versions
          @upgrade_versions ||= patched_versions.map do |version|
            parse_version(version)
          end
        end

        def parse_version(version)
          Versionomy.parse(version.to_s)
        rescue Versionomy::Errors::ParseError
          version = Versionomy.parse(version.to_s, :rubygems)
          Versionomy.create(major: version.field0, minor: version.field1, tiny: version.field2)
        end
      end
    end
  end
end
