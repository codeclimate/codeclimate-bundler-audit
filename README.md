# Code Climate bundler-audit Engine

[![Code Climate](https://codeclimate.com/repos/55841a7de30ba012e6020762/badges/20e726217fbdea3896db/gpa.svg)](https://codeclimate.com/repos/55841a7de30ba012e6020762/feed)

`codeclimate-bundler-audit` is a Code Climate engine that wraps [bundler-audit](https://github.com/rubysec/bundler-audit). You can run it on your command line using the Code Climate CLI, or on our hosted analysis platform.

bundler-audit offers patch-level verification for [Bundler](http://bundler.io/).

### Installation

1. If you haven't already, [install the Code Climate CLI](https://github.com/codeclimate/codeclimate).
2. Run `codeclimate engines:enable bundler-audit`. This command both installs the engine and enables it in your `.codeclimate.yml` file.
3. You're ready to analyze! Browse into your project's folder and run `codeclimate analyze`.

### Need help?

For help with bundler-audit, [check out their documentation](https://github.com/rubysec/bundler-audit).

If you're running into a Code Climate issue, first look over this project's [GitHub Issues](https://github.com/codeclimate/bundler-audit/issues), as your question may have already been covered. If not, [go ahead and open a support ticket with us](https://codeclimate.com/help).
