require 'blocks'

# Weaver class store all the information about a weaver file necessary
# to create the processed latex file
class Weaver
	attr_accessor :file, :blocks, :latex
	
	@blocks = []
	
	def file=(file)
		@file = Pathname.new(file)
		load
	end
	
	def cache_path
		file.parent + ("." + file_name + ".wcache")
	end
	
	def file_name
		file.to_s[0 .. file.to_s.length - file.extname.length - 1]
	end
	
	def initialize(file)
		self.file = file
	end
	
	def load
		block_type = {
			"" => Block,
			"=" => LatexBlock,
			"=g" => GraphicBlock,
			"=r" => RBlock
		}
		block_re = /<%(=?[rg]?)\s*(.*?)\s*%>/im
		
		
		@blocks = []

		self.latex = file.read.gsub(block_re) do |match|
			type, contents = $1, $2
			if block_type.include? type
				b = block_type[type].new(contents, cache_path)
				@blocks << b
			else 
				$stderr.puts "Unrecognised block type #{type}"
			end
			"#<Block:#{b.object_id}>"
		end
	end
	
	def process(remove_cache = false)
		FileUtils.rm "output.pdf", :force => true
		FileUtils.rm_r cache_path if remove_cache
		
		FileUtils.mkdir_p(cache_path)
		File.open(cache_path + "code.r", "w") { |f| f.write r_code }
		%x{r -q --no-save < #{cache_path + "code.r"} > #{cache_path + "r.log"} 2>&1}
		
		log = (cache_path + "r.log").readlines
		if log[-1].chomp == "Execution halted" 
			$stderr.puts "R error: "
			$stderr.puts log[-5..-2]
			$stderr.puts "see #{(cache_path + "r.log")} for more."
			exit
		end
		
		process_latex
		
		latex_path = cache_path + (file_name + ".tex")
		File.open(latex_path, "w") { |f| f.write latex }	
		%x{pdflatex  -interaction=nonstopmode -file-line-error-style -halt-on-error -output-directory=#{cache_path} #{latex_path}}	
		
		if File.exists? cache_path + (file_name + ".pdf")
			FileUtils.cp cache_path + (file_name + ".pdf"), file.parent + (file_name + ".pdf")
			`open #{file_name + ".pdf"}`
		end
		
	end
	
	def process_latex
		self.latex = latex.gsub(/#<([a-z]+):(.*?)>/i) { |match|
			id = $2.to_i
			ObjectSpace._id2ref(id.to_i).latex_code
		}
	end
	
	def r_cache
		cache_path + "cache.rdata"
	end
	
	def r_code
		r_header + blocks.map{|b| b.r_code}.join() + r_footer
	end
	
	def r_header
		%{
			# R code generated by weaver 
			# from #{file.realpath} on #{Date.today} 
			# ---------------------------------------------------------
			
			weaver.width <- 6
			weaver.height <- 4
			
			setwd("#{file.parent.realpath}")
			if (file.exists("#{r_cache}")) load("#{r_cache}")
			library(xtable)	
		}.gsub(/^\s*/, "")
	end

	def r_footer
		%{
			save(list = ls(all=TRUE), file= "#{r_cache}")
		}.gsub(/^\s*/, "")
	end
end