require 'generator'
require 'pathname'

# Documentation for a single R function
class R_Doc
	attr_accessor :block, :params, :function_params
	attr_reader :name, :title, :description, :usage

  def name
    @name.gsub(/"/, "")
  end
    
	# Name of documentation file
	def filename 
		name.gsub(/\[<-/, "-set-").gsub(/\[/,"-get-").gsub(/[^a-zA-Z\->]+/, "-").gsub(/-$/, "").gsub(/^-/, "") + "-" + name.hash.to_s(36)[1..2] + ".rd"
	end
	
	# Assign block to class and automatically parse
	def block=(block)
		@block = block
		parse_block!
	end
	
	# Parse block
	def parse_block!
		@title = comments[0]
		@description = comments[1]
		parse_function!
		parse_params!
	end
	
	# Full details about function.
	def details
		return nil if blank_comment_positions.length < 2 
		comments[blank_comment_positions[0]+1..blank_comment_positions[-1]-1].join("\n")
	end
	
	# Break block into array of comments
	def comments
		block.split("\n").select{|l| l =~ /^\s*#/}.map{|l| l.gsub(/^\s*#\s*/, "").strip}
	end
	
	# List of blank comment lines
	def blank_comment_positions
		pos = []
		comments.each_with_index{|value, index| pos << index if value == ""}
		pos
	end

	# Parse @xxxx parameters and put in @params hash
	def parse_params!
		@params = Hash.new {|hash, key| hash[key]= []}

		@params["author"] = ["Hadley Wickham <h.wickham@gmail.com>"]
		@params["alias"] << name
		
		block.split("\n").select{|l| l =~ /^\s*#\s*\@/}.each do |l|
			key, value = /^\s*#\s*\@([a-z]+)\s*(.*)$/.match(l).to_a[1..2]
			value.strip!
			@params[key] << value if value.strip.length > 0
		end
	end
	
	def parse_function!
		function_def, @name, function_params = /^([a-z0-9_+\[$."<\-]+)\s*<-\s*function(\((.|\n)*\))/i.match(block).to_a
		@usage = "#{@name}(#{matching_parens(function_params)})"
		@function_params = matching_parens(function_params).gsub(/\(.*?\)/,"").split(/\s*,\s*/).map{|p| p.gsub(/\=.*$/,"").strip}
	end
	
	def examples
		block.split("\n").select{|l| l =~ /^\s*#X/}.map{|l| l.gsub(/^\s*#X\s*/, "")}.join("\n")
	end

	def latex_param_alias
		params["alias"].map{|p| "\\alias{#{p}}"}.join("\n")
	end
	
	def latex_param_arguments
		items = SyncEnumerator.new(function_params, params["arguments"]).map do |arg, desc|
			"\\item{#{arg}}{#{desc}}"
		end.join("\n")
		"\\arguments{\n#{items}\n}"
	end
	
	def latex_param(name)
		params = @params[name]
		return nil if params.length == 0
		if params.length == 1
			"\\#{name}{" + params.to_s + "}"
		else
			"\\#{name}{\n" + params.map{|p| " \\item{#{p}}"}.join("\n") + "\n}"
		end
	end
	
	def keywords 
		params = @params["keyword"]
		return nil if params.length == 0
	  params.map{|p| "\\keyword{#{p}}"}.join("\n")
	end
	
	def latex_output
		<<LATEX
\\name{#{@name}}
#{latex_param_alias}
\\title{#{@title}}
#{latex_param("author")}

\\description{
#{@description}
}
\\usage{#{@usage}}
#{latex_param_arguments}
#{latex_param("value")}
\\details{#{details}}
#{latex_param("seealso")}
\\examples{#{examples}}
#{keywords}
LATEX
	end	
	
	def create_latex!(path)
	  puts @name
		File.open(path + filename, "w") { |f| f.write latex_output }
	end
	
	class << self
		def new_from_block(block)
			rd = R_Doc.new
			rd.block = block
			rd
		end
		
		# Create R man pages for all files in a directory.
		# Assumes that files laid out in typical r package fashion
		def document_path!(path ="/Users/hadley/documents/reshape/reshape/")
			source = Pathname.new(path)
			dest   = source + "man"
			r_files = Pathname.glob(source + "R/*.R") + Pathname.glob(source + "R/*.r")
			# puts r_files
			r_files.each do |path| 
			  self.document_file!(path, dest)
			end
		end
		
		# Document all functions in a file
		def document_file!(path, dest)
			file = Pathname.new(path)
			file.read.gsub(/(^#.*\n)+[^#\n ]+.*<-\s*function\((.*)\)/) do |match|
  		  begin
  				R_Doc.new_from_block(match).create_latex!(dest)
   			rescue 
   			  puts "Could not parse " + path
   			  puts match + "\n\n"
  			end
  		end
		end
	end
end

def paren_value(c)
  if c == "("
    1
  elsif c == ")"
    -1
  else
    0
  end
end

def matching_parens(string)
  y = 0
  cumsum = string.split("").map{|c| paren_value(c)}.map {|x| y +=x}
  first = cumsum.index(1)
  last = cumsum[first..string.length].index(0) + first
  string[(first+1)..(last-1)]
end