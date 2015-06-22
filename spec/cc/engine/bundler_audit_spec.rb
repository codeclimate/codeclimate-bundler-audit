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
    end
  end
end
