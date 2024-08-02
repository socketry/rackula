# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Dave Wilkinson.

require 'samovar'

require 'pathname'
require 'fileutils'
require 'rack'

require 'falcon/server'

require 'io/endpoint/host_endpoint'
require 'async/container'
require 'async/http'

require 'variant'

module Rackula
	module Command
		# Server setup commands.
		class Generate < Samovar::Command
			self.description = "Start a local server and generate a static version of a site."
			
			options do
				option '-c/--config <path>', "Rackup configuration file to load.", default: 'config.ru'
				option '-p/--public <path>', "The public path to copy initial files from.", default: 'public'
				option '-o/--output-path <path>', "The output path to save static site.", default: 'static'
				
				option '-f/--force', "If the output path exists, delete it.", default: false
			end
			
			def copy_and_fetch(port, root)
				output_path = File.expand_path(@options[:output_path], root)
				
				if File.exist?(output_path)
					if @options[:force]
						# Delete any existing stuff:
						FileUtils.rm_rf(output_path.to_s)
					end
				end
				
				# Create output directory
				FileUtils.mkdir_p(output_path)
				
				# Copy all public assets:
				asset_pattern = root + @options[:public] + '*'
				Dir.glob(asset_pattern.to_s).each do |path|
					FileUtils.cp_r(path, File.join(output_path, "."))
				end
				
				# Generate HTML pages:
				unless system("wget", "--mirror", "--recursive", "--convert-links", "--adjust-extension", "--no-host-directories", "--directory-prefix", output_path.to_s, "http://localhost:#{port}")
					raise "The wget command failed!"
				end
			end
			
			def serve(endpoint, root)
				container = Async::Container.new
				
				config_path = root + @options[:config]
				
				container.run do |instance|
					Sync do
						rack_app, _ = Rack::Builder.parse_file(config_path.to_s)
						app = ::Falcon::Server.middleware(rack_app, verbose: @options[:verbose])
						server = ::Falcon::Server.new(app, endpoint)
						
						instance.ready!
						
						server.run
					end
				end
				
				container.wait_until_ready
				
				return container
			end
			
			def run(bound_endpoint, root)
				# We need to determine the actual port we are bound to:
				local_addresses = bound_endpoint.sockets.map(&:local_address)
				address = local_addresses.first
				
				endpoint = Async::HTTP::Endpoint.parse("http://localhost", bound_endpoint)
				
				Console.logger.info(self) {"Setting up container to serve site on port #{address.ip_port}..."}
				container = serve(endpoint, root)
				
				Console.logger.info(self) {"Copy and fetch site to static..."}
				copy_and_fetch(address.ip_port, root)
			ensure
				container&.stop
			end
			
			def call
				Variant.force!('static')
				
				endpoint = ::IO::Endpoint.tcp("localhost", 0, reuse_port: true)
				
				begin
					bound_endpoint = endpoint.bound
					
					run(bound_endpoint, Pathname.new(parent.root))
				ensure
					bound_endpoint&.close
				end
			end
		end
	end
end
