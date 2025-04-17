task :serve do |t|
	additional_options = ''
	if ![nil, '', '0'].include?(ENV['JEKYLL_SSL'])
		if !File.exist?('_ssl/server.key') || !File.exist?('_ssl/server.crt')
			if !File.exist?('_ssl/ca.key') || !File.exist?('_ssl/ca.crt')
				system 'openssl req -x509 -nodes -days 31227 -keyout _ssl/ca.key -out _ssl/ca.crt -config _ssl/ca.cnf'
				puts 'Trust _ssl/ca.crt in browser settings.'
			end
			system 'openssl req -new -nodes -keyout _ssl/server.key -out _ssl/server.csr -config _ssl/server.cnf'
			system 'openssl x509 -req -in _ssl/server.csr -days 31227 -CA _ssl/ca.crt -CAkey _ssl/ca.key -CAcreateserial -out _ssl/server.crt -extensions v3_req -extfile _ssl/sign.cnf'
		end
		additional_options = '--ssl-key _ssl/server.key --ssl-cert _ssl/server.crt'
	end
	exec "jekyll serve --incremental --host 0.0.0.0 --port 4000 #{additional_options}"
end

task :build do |t|
	exec 'jekyll build'
end

task default: :serve
