module Jekyll::UlyssesZhan
end

module Jekyll
	module UlyssesZhan::Filters
		def dirname input
			File.dirname input
		end
	end
end
Liquid::Template.register_filter Jekyll::UlyssesZhan::Filters
