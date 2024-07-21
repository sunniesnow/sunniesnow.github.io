# frozen_string_literal: true

task :serve do |t|
	exec 'bundle exec jekyll serve --incremental --host 0.0.0.0 --port 4000 --livereload'
end

task :build do |t|
	exec 'bundle exec jekyll build'
end

task default: :serve
