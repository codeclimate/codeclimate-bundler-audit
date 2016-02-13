require "spec_helper"

module CC::Engine::BundlerAudit
  describe UnpatchedGemRemediation do
    describe "#points" do
      it "returns major upgrade remediation points when an upgrade requies a major version bump" do
        remediation = UnpatchedGemRemediation.new("1.0.0", %w[2.0.1 3.0.1])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MAJOR_UPGRADE_POINTS)
      end

      it "returns minor upgrade remediation points when an upgrade requies a minor version bump" do
        remediation = UnpatchedGemRemediation.new("1.0.0", %w[1.2.1 2.2.1])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MINOR_UPGRADE_POINTS)
      end

      it "returns tiny upgrade remediation points when an upgrade requies a tiny version bump" do
        remediation = UnpatchedGemRemediation.new("1.0", %w[1.0.2])

        expect(remediation.points).to eq(UnpatchedGemRemediation::TINY_UPGRADE_POINTS)
      end

      it "returns minimum upgrade remediation points when an upgrade requies a <= tiny2 version bump" do
        remediation = UnpatchedGemRemediation.new("1.0", %w[1.0.0.2-2])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MINIMUM_UPGRADE_POINTS)

        remediation = UnpatchedGemRemediation.new("1.0", %w[1.0.0.2-2])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MINIMUM_UPGRADE_POINTS)

        remediation = UnpatchedGemRemediation.new("1.0", %w[1.0a2])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MINIMUM_UPGRADE_POINTS)

        remediation = UnpatchedGemRemediation.new("1.0", %w[1.0b2])

        expect(remediation.points).to eq(UnpatchedGemRemediation::MINIMUM_UPGRADE_POINTS)
      end

      it "returns unpatched version remediation points when an upgrade is not possible" do
        remediation = UnpatchedGemRemediation.new("1.0.0", [])

        expect(remediation.points).to eq(UnpatchedGemRemediation::UNPATCHED_VERSION_POINTS)
      end
    end
  end
end
