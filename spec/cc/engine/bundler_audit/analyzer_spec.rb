require "spec_helper"

module CC::Engine::BundlerAudit
  describe Analyzer do
    describe "#run" do
      it "raises an error when no Gemfile.lock exists" do
        directory = fixture_directory("no_gemfile_lock")

        expect { Analyzer.new(directory: directory).run }.
          to raise_error(Analyzer::GemfileLockNotFound)
      end

      it "emits issues for unpatched gems in Gemfile.lock" do
        directory = fixture_directory("unpatched_versions")

        issues = analyze_directory(directory)

        expect(issues).to eq(expected_issues("unpatched_versions"))
      end

      it "emits issues for insecure sources in Gemfile.lock" do
        directory = fixture_directory("insecure_source")

        issues = analyze_directory(directory)

        expect(issues).to eq(expected_issues("insecure_source"))
      end

      it "logs to stderr when we encounter an unsupported vulnerability" do
        directory = fixture_directory("unpatched_versions")
        stderr = StringIO.new

        stub_vulnerability("UnhandledVulnerability")

        analyze_directory(directory, stderr: stderr)

        expect(stderr.string).to eq("Unsupported vulnerability: UnhandledVulnerability")
      end

      def analyze_directory(directory, stdout: StringIO.new, stderr: StringIO.new)
        audit = Analyzer.new(directory: directory, stdout: stdout, stderr: stderr)
        audit.run

        stdout.string.split("\0").map { |issue| JSON.load(issue) }
      end

      def stub_vulnerability(name)
        scanner = double(:scanner)
        vulnerability = double(:vulnerability, class: double(name: name))

        allow(Bundler::Audit::Scanner).to receive(:new).and_return(scanner)
        allow(scanner).to receive(:scan).and_yield(vulnerability)
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
