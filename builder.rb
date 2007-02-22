def build_package(name, repos = "~/ggobi/web/v2/r") 
	version = "2.4.1"
  name = name.gsub(/\/$/, "")
	`R CMD build #{name}`
	fullname = Dir["#{name}*.tar.gz"].to_s.gsub(".tar.gz", "")

	`R CMD build --binary #{name}`
	macname = Dir["#{name}*i386-apple-darwin*.tar.gz"].to_s
	
	`mv #{macname} #{fullname}.tgz`

	if (!File.exists?("#{name}/src"))
		curdir = `pwd`.chomp
		`R CMD install #{name}`
		`cd ~/library/R/library/; zip -r9X #{name} #{name}; mv #{name}.zip #{curdir}/#{fullname}.zip`
	end

	if repos
		`mkdir #{repos}/bin/windows/contrib/#{version}/`
		`mkdir #{repos}/bin/macosx/universal/contrib/#{version}/`
		`mkdir #{repos}/bin/macosx/powerpc/contrib/#{version}/`
		`mkdir #{repos}/bin/macosx/i386/contrib/#{version}/`
	
		`mv #{fullname}.zip #{repos}/bin/windows/contrib/#{version}/`
		`cp #{fullname}.tgz  #{repos}/bin/macosx/universal/contrib/#{version}/`
		`cp #{fullname}.tgz  #{repos}/bin/macosx/powerpc/contrib/#{version}/`
		`mv #{fullname}.tgz  #{repos}/bin/macosx/i386/contrib/#{version}/`
	 	`mv #{fullname}.tar.gz  #{repos}/src/contrib/`
	
		`cd #{repos}/`
	end
end