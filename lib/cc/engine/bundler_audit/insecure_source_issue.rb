module CC
  module Engine
    module BundlerAudit
      class InsecureSourceIssue
        CHECK_NAME = "Insecure Source".freeze
        REMEDIATION_POINTS = 5_000_000
        SOURCE_REGEX = /^\s*remote: (?<source>\S+)/

        def initialize(result, gemfile_lock_lines)
          @source = result.source
          @gemfile_lock_lines = gemfile_lock_lines
        end

        def to_json(*a)
          {
            categories: %w[Security],
            check_name: CHECK_NAME,
            content: {
              body: "",
            },
            description: "Insecure Source URI found: #{source}",
            location: {
              path: "Gemfile.lock",
              lines: {
                begin: line_number,
                end: line_number,
              },
            },
            remediation_points: REMEDIATION_POINTS,
            severity: "normal",
            type: "Issue",
            fingerprint: BundlerAudit.fingerprint_for(CHECK_NAME, source),
          }.to_json(a)
        end

        private

        attr_reader :source, :gemfile_lock_lines

        def line_number
          @line_number ||= begin
            gemfile_lock_lines.find_index do |line|
              (match = SOURCE_REGEX.match(line)) && match[:source] == source
            end + 1
          end
        end
      end
    end
  end
end
