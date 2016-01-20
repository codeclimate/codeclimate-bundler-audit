require "spec_helper"

module CC::Engine
  describe BundlerAudit do
    describe "#run" do
      it "raises an error when no Gemfile.lock exists" do
        FakeFS do
          directory = "/c"
          FileUtils.mkdir_p(directory)
          io = StringIO.new
          config = {}

          expect { BundlerAudit.new(directory: directory, io: io, engine_config: config).run }
            .to raise_error(CC::Engine::BundlerAudit::GemfileLockNotFound)
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
          categories: ["Security"],
          check_name: "Insecure Dependency",
          content: {
            body: "**Advisory**: OSVDB-91452\n\n**Criticality**: Medium\n\n**URL**: http://www.osvdb.org/show/osvdb/91452\n\n**Solution**: upgrade to ~> 2.3.18, ~> 3.1.12, >= 3.2.13"
          },
          description: "XSS vulnerability in sanitize_css in Action Pack",
          location: {
            path: "Gemfile.lock",
            lines: { begin: nil, end: nil }
          },
          remediation_points: 500_000,
          severity: "normal",
          type: "Issue",
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

        expect(io.string).to eq("#{result}\0")
      end
    end
  end
end
