#include <istream>

#include "n_parser.hpp"
#include "n_lexer.hpp"
#include "n_syntax.hpp"

namespace compiler { namespace parser {

n_parser::n_parser(std::istream& input)
{
    ast::program* tree;
    n_lexer lexer(&input);
    n_syntax syntax(tree, lexer);
    if(syntax.parse() != 0)
	{ /* TODO: бросить исключение */}
	else
		program_.reset(tree);
}

ast::program* n_parser::tree() const { return program_.get(); }

}}