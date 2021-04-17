
require_relative "lib/rackula/version"

Gem::Specification.new do |spec|
	spec.name = "rackula"
	spec.version = Rackula::VERSION
	
	spec.summary = "Generate a static site from any rackup compatible application."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/rackula"
	
	spec.files = Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["rackula"]
	
	spec.add_dependency "falcon", "~> 0.34"
	spec.add_dependency "samovar", "~> 2.1"
	spec.add_dependency "variant"
	
	spec.add_development_dependency "bake-bundler"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
