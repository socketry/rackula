
require 'rack'

run Proc.new { |env|
	# Extract the requested path from the request
	path = env["PATH_INFO"]
	path = "index.html" if path == "/"
	
	full_path = File.join(__dir__, path)
	
	if File.exist?(full_path)
		[200, {}, [File.read(full_path)]]
	else
		[404, {}, []]
	end
}