require "spec_helper"

describe "bin/bundler-audit" do
  it "doesn't crash when run in isolation" do
    # all this environment rigamarole is intended to invoke the bin script
    # in isolation. Running RSpec via bundler pollutes the environment with
    # variables that alter the behavior of the engine, specifically setting
    # BUNDLE_GEMFILE to point to the Gemfile _of the engine_, which is then
    # used by bundler to look up the Gemfile and satisfy its expectation that
    # a Gemfile exist alongside a Gemfile.lock
    expected_env = {
      "HOME" => ENV["HOME"],
      "HOSTNAME" => ENV["HOSTNAME"],
      "PATH" => ENV["PATH"],
    }
    success = system(expected_env, "bin/bundler-audit spec/fixtures/insecure_sources >/dev/null", unsetenv_others: true)
    expect(success).to be true
  end
end
