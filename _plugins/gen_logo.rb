# frozen_string_literal: true

require 'open-uri'

module Jekyll::UlyssesZhan
end

module Jekyll
	class UlyssesZhan::LogoGenerator < Generator
		safe true
		priority :low
		def generate site
			site.pages.push UlyssesZhan::LogoIco.new site
			site.pages.push UlyssesZhan::LogoSvg.new site
		end
	end

	class UlyssesZhan::LogoIco < Page

		URL = 'https://github.com/sunniesnow/logo/releases/download/v1.1/logo.ico'

		def initialize site
			@site = site
			@base = site.source
			@dir = '.'
			@name = 'favicon.ico'
			process @name
			@data = {}
			@content = URI.open URL, &:read
		end
	end

	class UlyssesZhan::LogoSvg < Page

		URL = 'https://github.com/sunniesnow/logo/releases/download/v1.1/logo.svg'

		def initialize site
			@site = site
			@base = site.source
			@dir = '.'
			@name = 'favicon.svg'
			process @name
			@data = {}
			@content = URI.open URL, &:read
		end
	end
end
