# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'samovar'

require 'pathname'
require 'fileutils'
require 'rack'

require 'falcon/server'

require 'async/io'
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
				output_path = root + @options[:output_path]
				
				if output_path.exist?
					if @options[:force]
						# Delete any existing stuff:
						FileUtils.rm_rf(output_path.to_s)
					else
						# puts "Failing due to error..."
						raise Samovar::Failure.new("Output path already exists!")
					end
				end
				
				# Create output directory
				Dir.mkdir(output_path)
				
				# Copy all public assets:
				asset_pattern = root + @options[:public] + '*'
				Dir.glob(asset_pattern.to_s).each do |path|
					FileUtils.cp_r(path, File.join(output_path, "."))
				end
				
				# Generate HTML pages:
				unless system("wget", "--mirror", "--recursive", "--continue", "--convert-links", "--adjust-extension", "--no-host-directories", "--directory-prefix", output_path.to_s, "http://localhost:#{port}")
					raise "The wget command failed!"
				end
			end
			
			def serve(endpoint, root)
				container = Async::Container.new
				
				config_path = root + @options[:config]
				
				container.run do |instance|
					Async do
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
			
			def run(address, root)
				endpoint = Async::HTTP::Endpoint.parse("http://localhost", port: address.ip_port, reuse_port: true)
				
				Console.logger.info(self) {"Setting up container to serve site on port #{address.ip_port}..."}
				container = serve(endpoint, root)
				
				# puts "Copy and fetch site to static..."
				copy_and_fetch(address.ip_port, root)
			ensure
				container&.stop
			end
			
			def call
				Variant.force!('static')
				
				endpoint = Async::IO::Endpoint.tcp("localhost", 0, reuse_port: true)
				
				# We bind to a socket to generate a temporary port:
				socket = Sync{endpoint.each.first.bind}
				
				run(socket.local_address, Pathname.new(parent.root))
			end
		end
	end
end
