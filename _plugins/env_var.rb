module Jekyll::UlyssesZhan
end

module Jekyll
	class UlyssesZhan::EnvVarGenerator < Generator
		safe true
		priority :high

		PREFIX = 'SUNNIESNOW_'

		def generate site
			ENV.each do |key, value|
				next unless key.start_with? PREFIX
				site.config[key.downcase] = value
			end
		end
	end
end
