# frozen_string_literal: true

require_relative "lib/rackula/version"

Gem::Specification.new do |spec|
	spec.name = "rackula"
	spec.version = Rackula::VERSION
	
	spec.summary = "Generate a static site from any rackup compatible application."
	spec.authors = ["Samuel Williams", "Dave Wilkinson", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/rackula"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/rackula/",
		"source_code_uri" => "https://github.com/socketry/rackula.git",
	}
	
	spec.files = Dir.glob(['{bin,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["rackula"]
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "falcon", "~> 0.46"
	spec.add_dependency "samovar", "~> 2.1"
	spec.add_dependency "variant"
end
