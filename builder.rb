
name = "ggplot"

def build_package(name, repos = "~/ggobi/web/v2/r")
	`R CMD build #{name}`
	fullname = Dir["#{name}*.tar.gz"].to_s.gsub(".tar.gz", "")

	`R CMD build --binary #{name}`
	macname = Dir["*powerpc-apple-darwin*.tar.gz"].to_s
	`mv #{macname} #{fullname}.tgz`

	if (!File.exists?("#{name}/src"))
		curdir = `pwd`.chomp
		`R CMD install #{name}`
		`cd ~/library/R/library/; zip -r9X #{name} #{name}; mv #{name}.zip #{curdir}/#{fullname}.zip`
	end


	if repos
		`mv #{fullname}.zip #{repos}/bin/windows/contrib/2.3/`
		`mv #{fullname}.tgz  #{repos}/bin/macosx/powerpc/contrib/2.3/`
	 	`mv #{fullname}.tar.gz  #{repos}/src/contrib/`
	
		`cd #{repos}/`
	end
end