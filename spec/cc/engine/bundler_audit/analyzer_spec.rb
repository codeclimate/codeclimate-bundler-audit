require "spec_helper"

module CC::Engine::BundlerAudit
  describe Analyzer do
    describe "#run" do
      it "raises an error when no Gemfile.lock exists" do
        directory = fixture_directory("no_gemfile_lock")
        io = StringIO.new

        expect { Analyzer.new(directory: directory, io: io).run }.
          to raise_error(Analyzer::GemfileLockNotFound)
      end

      it "emits issues for unpatched gems in Gemfile.lock" do
        io = StringIO.new
        directory = fixture_directory("unpatched_versions")

        issues = analyze_directory(directory, io)

        expect(issues).to eq(expected_issues("unpatched_versions"))
      end

      it "emits issues for insecure sources in Gemfile.lock" do
        io = StringIO.new
        directory = fixture_directory("insecure_source")

        issues = analyze_directory(directory, io)

        expect(issues).to eq(expected_issues("insecure_source"))
      end

      def analyze_directory(directory, io)
        audit = Analyzer.new(directory: directory, io: io)
        audit.run

        io.string.split("\0").map { |issue| JSON.load(issue) }
      end

      def expected_issues(fixture)
        path = File.join(fixture_directory(fixture), "issues.json")
        body = File.read(path)
        JSON.load(body)
      end

      def fixture_directory(fixture)
        File.join(Dir.pwd, "spec", "fixtures", fixture)
      end
    end
  end
end
