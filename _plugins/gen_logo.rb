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

	class UlyssesZhan::Logo < StaticFile

		URL_WITHOUT_EXTENSION = 'https://github.com/sunniesnow/logo/releases/download/v1.1/logo'
		TEMP_DIR = '_tmp'

		def initialize extension, site
			super site, site.source, '.', "favicon.#{extension}"
			download_contents
		end

		def path
			@path ||= File.join TEMP_DIR, @name
		end

		def download_contents
			return if File.exist? path
			FileUtils.mkdir_p File.dirname path
			URI.open URL_WITHOUT_EXTENSION + @ext do |r|
				File.write path, r.read
			end
		end
	end
end
