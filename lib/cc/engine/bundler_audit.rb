require 'json'
require 'versionomy'

module CC
  module Engine
    class BundlerAudit
      GemfileLockNotFound = Class.new(StandardError)
      SEVERITIES = {
        "High" => "critical",
        "Low" => "info",
        "Medium" => "normal",
      }

      def initialize(directory: , io: , engine_config: )
        @directory = directory
        @engine_config = engine_config
        @io = io
      end

      def run
        if gemfile_lock_exists?
          Dir.chdir(@directory)
          raw_output = `bundle-audit`
          raw_issues = raw_output.split(/\n\n/).select { |chunk|
            chunk =~ /^Name: /
          }
          @gemfile_lock_lines = File.read(
            File.join(@directory, 'Gemfile.lock')
          ).lines
          raw_issues.each do |raw_issue|
            issue = issue_from_raw(raw_issue)
            @io.print("#{issue.to_json}\0")
          end
        else
          raise GemfileLockNotFound, "No Gemfile.lock found."
        end
      end

      private

      def gemfile_lock_exists?
        File.exist?(File.join(@directory, 'Gemfile.lock'))
      end

      def issue_from_raw(raw_issue)
        raw_issue_hash = {}
        raw_issue.lines.each do |l|
          l =~ /^([^:]+): (.+)\n?/
          raw_issue_hash[$1] = $2
        end
        line_number = nil
        @gemfile_lock_lines.each_with_index do |l, i|
          if l =~ /^\s*#{raw_issue_hash['Name']} \([\d.]+\)/
              line_number = i + 1
          end
        end
        {
          categories: ['Security'],
          check_name: "Insecure Dependency",
          content: {
            body: content_body(raw_issue_hash)
          },
          description: raw_issue_hash['Title'],
          location: {
            path: 'Gemfile.lock',
            lines: {
              begin: line_number,
              end: line_number
            }
          },
          remediation_points: remediation_points(
            raw_issue_hash['Version'], raw_issue_hash['Solution']
          ),
          severity: SEVERITIES[raw_issue_hash["Criticality"]],
          type: 'Issue',
        }
      end

      def remediation_points(current_version, raw_solution)
        if raw_solution =~ /^upgrade to (.*)/
          raw_upgrades = $1.scan(/\d+\.\d+\.\d+/)
          current_version = Versionomy.parse(current_version)
          result = 5_000_000_000
          raw_upgrades.each do |raw_upgrade|
            upgrade_version = Versionomy.parse(raw_upgrade)
            if upgrade_version > current_version
              points_this_upgrade = nil
              if current_version.major == upgrade_version.major
                if current_version.minor == upgrade_version.minor
                  points_this_upgrade = 500_000 # patch upgrade
                else
                  points_this_upgrade = 5_000_000 # minor upgrade
                end
              else
                points_this_upgrade = 50_000_000 # major upgrade
              end
              result = points_this_upgrade if points_this_upgrade < result
            end
          end
          result
        else
          500_000_000 # No upgrade of gem possible
        end
      end

      def content_body(raw_issue_hash)
        %w[Advisory Criticality URL Solution].map do |key|
          "**#{key}**: #{raw_issue_hash[key]}"
        end.join("\n\n")
      end
    end
  end
end

