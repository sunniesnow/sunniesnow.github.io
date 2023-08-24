# frozen_string_literal: true

lib = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib
Gem::Specification.new do |spec|
	spec.name = 'gen_katex'
	spec.version = '0.1.0'
	spec.authors = ['UlyssesZhan']
	spec.summary = ""
	spec.files = Dir['lib/**/*.rb']
end
