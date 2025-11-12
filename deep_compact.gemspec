# frozen_string_literal: true

require_relative "lib/deep_compact/version"

Gem::Specification.new do |spec|
  spec.name = "deep_compact"
  spec.version = DeepCompact::VERSION
  spec.authors = ["Italo Matos"]
  spec.email = ["italomatos@gmail.com"]

  spec.summary = "Deep compact methods for Ruby Hash to remove nil/blank values recursively"
  spec.description = "Adds deep_compact and deep_compact_blank methods to Hash class that recursively remove nil or blank values from nested hashes and arrays, including removing keys whose values become empty after compaction."
  spec.homepage = "https://github.com/italomatos/deep_compact"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/italomatos/deep_compact"
  spec.metadata["changelog_uri"] = "https://github.com/italomatos/deep_compact/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "activesupport", ">= 6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
