# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.

require_relative 'version'

require_relative 'command/generate'

module Rackula
	module Command
		def self.call(*args)
			Top.call(*args)
		end
		
		# The top level utopia command.
		class Top < Samovar::Command
			self.description = "A static site generation tool."
			
			options do
				option '-i/--in/--root <path>', "Work in the given root directory."
				option '-h/--help', "Print out help information."
				option '-v/--version', "Print out the application version."
			end
			
			nested :command, {
				'generate' => Generate
			}, default: 'generate'
			
			# The root directory for the site.
			def root
				File.expand_path(@options.fetch(:root, ''), Dir.getwd)
			end
			
			def call
				if @options[:version]
					puts "#{self.name} v#{VERSION}"
				elsif @options[:help]
					print_usage(output: $stdout)
				else
					@command.call
				end
			end
		end
	end
end
