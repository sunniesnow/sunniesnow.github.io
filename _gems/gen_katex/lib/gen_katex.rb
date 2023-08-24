# frozen_string_literal: true

require 'execjs'
require 'open-uri'

require 'jekyll'

module Jekyll
	module Katex
		PATH = 'tmp/katex.min.js'
		uri = 'https://fastly.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.js'
		unless File.exist? PATH
			FileUtils.mkdir_p 'tmp'
			File.write PATH, URI.open(uri, &:read)
		end
		KATEX_JS ||= ExecJS.compile File.read PATH
	end
end
