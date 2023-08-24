# frozen_string_literal: true

require 'open-uri'

module Jekyll::UlyssesZhan
end

module Jekyll
	class UlyssesZhan::LogoGenerator < Generator
		safe true
		priority :low
		def generate site
			push_logo site, 'ico'
			push_logo site, 'svg'
			push_logo site, 'png'
		end

		def push_logo site, extension
			site.static_files.push UlyssesZhan::Logo.new extension, site
		end
	end

	class UlyssesZhan::Logo < Page

		URL_WITHOUT_EXTENSION = 'https://github.com/sunniesnow/logo/releases/download/v1.1/logo'

		def initialize extension, site
			@site = site
			@base = site.source
			@dir = '.'
			@name = "favicon.#{extension}"
			process @name
			@data = {}
			@content = get_content
		end

		def get_content
			unless File.exist? File.join 'tmp', @name
				FileUtils.mkdir_p 'tmp'
				File.write File.join('tmp', @name), URI.open(URL_WITHOUT_EXTENSION + @ext, &:read)
			end
			File.read File.join 'tmp', @name
		end
	end
end
