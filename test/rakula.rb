# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2018, by Dave Wilkinson.

require 'rackula/command'

describe Rackula do
	let(:root) {File.expand_path(".site/", __dir__)}
	let(:output_path) {File.expand_path(".static/", __dir__)}
	
	it "can generate copy of site" do
		Rackula::Command::Top["--root", root, "generate", "--force", "--output-path", output_path].call
		
		expect(File).to be(:exist?, File.join(output_path, "index.html"))
		expect(File).to be(:exist?, File.join(output_path, "another.html"))
		expect(File).to be(:exist?, File.join(output_path, "document.txt"))
	end
	
	it "can generate copy of site into existing directory" do
		FileUtils.mkdir_p(output_path)
		FileUtils.touch(File.join(output_path, "existing.txt"))
		
		Rackula::Command::Top["--root", root, "generate", "--output-path", output_path].call
		
		expect(File).to be(:exist?, File.join(output_path, "index.html"))
		expect(File).to be(:exist?, File.join(output_path, "another.html"))
		expect(File).to be(:exist?, File.join(output_path, "document.txt"))
		
		expect(File).to be(:exist?, File.join(output_path, "existing.txt"))
	end
end
