module Jekyll::UlyssesZhan
end

module Jekyll
	module UlyssesZhan::GitInfoHelpers
		def self.git_log context, format
			page = context.registers[:page]
			file_path = page['path'] if page.is_a? Hash
			site_source = context.registers[:site].source
			dir = if file_path
				full_path = File.expand_path file_path, site_source
				File.directory?(full_path) ? full_path : File.dirname(full_path)
			else
				site_source
			end
			output = `git -C "#{dir}" log -1 --format="#{format}"`.strip
			output.empty? ? 'N/A' : output
		end
	end

	class UlyssesZhan::CommitHashTag < Liquid::Tag
		def render context
			UlyssesZhan::GitInfoHelpers.git_log context, '%H'
		end
	end

	class UlyssesZhan::CommitDateTag < Liquid::Tag
		def render context
			UlyssesZhan::GitInfoHelpers.git_log context, '%cI'
		end
	end
end

Liquid::Template.register_tag 'commit_hash', Jekyll::UlyssesZhan::CommitHashTag
Liquid::Template.register_tag 'commit_date', Jekyll::UlyssesZhan::CommitDateTag
