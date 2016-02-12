require "spec_helper"

module CC::Engine::BundlerAudit
  describe Remediation do
    describe "#points" do
      it "returns major upgrade remediation points when an upgrade requies a major version bump" do
        remediation = Remediation.new("1.0.0", %w[2.0.1 3.0.1])

        expect(remediation.points).to eq(Remediation::MAJOR_UPGRADE_POINTS)
      end

      it "returns minor upgrade remediation points when an upgrade requies a minor version bump" do
        remediation = Remediation.new("1.0.0", %w[1.2.1 2.2.1])

        expect(remediation.points).to eq(Remediation::MINOR_UPGRADE_POINTS)
      end

      it "returns patch upgrade remediation points when an upgrade requies a patch version bump" do
        remediation = Remediation.new("1.0.0", %w[1.0.3 2.0.3])

        expect(remediation.points).to eq(Remediation::PATCH_UPGRADE_POINTS)
      end

      it "returns unpatched version remediation points when an upgrade is not possible" do
        remediation = Remediation.new("1.0.0", [])

        expect(remediation.points).to eq(Remediation::UNPATCHED_VERSION_POINTS)
      end
    end
  end
end
