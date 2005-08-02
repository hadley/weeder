require 'test/unit'
require 'weeder'

class Weeder_Test < Test::Unit::TestCase #:nodoc:


	def test_parse_comments()
		comment_block = %{
			# Title
			# Brief description.
			#
			# Full details
			# May span many lines.
			#
			# @alias cheese
			# @arguments list of function arguments 
			# @arguments in same order as function def
			# @arguments remaining to be past on down
			# @value what the function returns
			# @value multiple returns correspond to 
			# @seealso 
			# @references
			# @keyword
			test <- function(a=3, b=c, ...) {}
			# #examples go here
			# print(a)
			}#.gsub(/$\s+/, "")
		
		parsed = R_Doc.new_from_block(comment_block)
		
		assert_equal("test", parsed.name)
		assert_equal("Title", parsed.title)
		assert_equal("Brief description.", parsed.description)
		assert_equal("Full details\nMay span many lines.", parsed.details)
		assert_equal(["test", "cheese"], parsed.params["alias"])
		assert_equal(["list of function arguments", "in same order as function def","remaining to be past on down"], parsed.params["arguments"])
		assert_equal(["a", "b", "..."], parsed.function_params)
		assert_equal("test(a=3, b=c, ...)", parsed.usage)
	end
	

end