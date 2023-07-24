# frozen_string_literal: true

require 'open-uri'

module Jekyll::UlyssesZhan
end

module Jekyll
	class UlyssesZhan::LogoGenerator < Generator
		safe true
		priority :low
		def generate site
			site.pages.push UlyssesZhan::Logo.new site
		end
	end

	class UlyssesZhan::Logo < Page
		def initialize site
			@site = site
			@base = site.source
			@dir = '.'
			@name = 'favicon.ico'
			process @name
			@data = {}
			@content = URI.open site.config['logo'], &:read
		end
	end
end