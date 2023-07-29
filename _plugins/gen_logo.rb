# frozen_string_literal: true

require 'open-uri'

module Jekyll::UlyssesZhan
end

module Jekyll
	class UlyssesZhan::LogoGenerator < Generator
		safe true
		priority :low
		def generate site
			site.pages.push UlyssesZhan::Logo.new 'ico', site
			site.pages.push UlyssesZhan::Logo.new 'svg', site
			site.pages.push UlyssesZhan::Logo.new 'png', site
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
			@content = URI.open "#{URL_WITHOUT_EXTENSION}.#{extension}", &:read
		end
	end
end
