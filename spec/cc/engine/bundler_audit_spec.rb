require "spec_helper"

module CC::Engine
  describe BundlerAudit do
    describe "#run" do
      it "emits a warning when no Gemfile exists" do
        FakeFS do
          directory = "/c"
          FileUtils.mkdir_p(directory)
          io = StringIO.new
          config = {}

          BundlerAudit.new(directory: directory, io: io, engine_config: config).run

          expect(io.string).to match(%{{"type":"warning","description":"No Gemfile.lock file found"}})
        end
      end

      it "emits issues for Gemfile.lock problems" do
        bundle_audit_output = <<-EOF
Name: actionpack
Version: 3.2.10
Advisory: OSVDB-91452
Criticality: Medium
URL: http://www.osvdb.org/show/osvdb/91452
Title: XSS vulnerability in sanitize_css in Action Pack
Solution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13
        EOF
        result = {
          type: "Issue",
          check_name: "Insecure Dependency",
          description: "XSS vulnerability in sanitize_css in Action Pack",
          categories: ["Security"],
          remediation_points: 500000,
          location: {
            path: "Gemfile.lock",
            lines: { begin: nil, end: nil }
          },
          content: {
            body: "Advisory: OSVDB-91452\n\nCriticality: Medium\n\nURL: http://www.osvdb.org/show/osvdb/91452\n\nSolution: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13"
          },
        }.to_json
        io = StringIO.new
        directory = "/c"
        config = {}

        FakeFS do
          FileUtils.mkdir_p(directory)
          FileUtils.touch("/c/Gemfile.lock")

          audit = BundlerAudit.new(directory: directory, io: io, engine_config: config)

          allow(audit).to receive(:`).and_return(bundle_audit_output)

          audit.run
        end

        expect(io.string).to match("#{result}\0")
      end
    end
  end
end
