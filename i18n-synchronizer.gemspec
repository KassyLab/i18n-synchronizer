# frozen_string_literal: true

require_relative "lib/i18n/synchronizer/version"

Gem::Specification.new do |spec|
  spec.name          = "i18n-synchronizer"
  spec.version       = I18n::Synchronizer::VERSION
  spec.authors       = ["Damien DANGLARD"]
  spec.email         = ["damien.danglard@kassylab.com"]

  spec.summary       = "Command line tools for synchronize localizations"
  spec.description   = "This command line tools can synchronize localizations from Android and iOS project. All localization need to be stored in git repository."
  spec.homepage      = "https://github.com/KassyLab"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KassyLab/i18n-synchronizer.git"
  spec.metadata["changelog_uri"] = "https://github.com/KassyLab/i18n-synchronizer/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
