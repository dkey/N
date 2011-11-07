

%{
#include "parser/stype.hpp"
#include "n_syntax.hpp"
#include "parser/n_lexer.hpp"

#define YY_USER_ACTION yylloc->columns(yyleng);
#define yyterminate() return compiler::parser::n_syntax::token::END

#define NAMESPACE namespace compiler { namespace parser {
#define CLOSE_NAMESPACE }}
//NAMESPACE
%}

%option noyywrap
%option nounput
%option never-interactive
%option nounistd
%option c++
%option yyclass="n_lexer"

spaces                          [ ]|\t
line_terminator                 \n|\r\n
decimal_integer                 [0-9]([0-9_]*[0-9])?
hex_integer                     (0x|0X)[0-9a-fA-F]+
octal_integer                   0o[0-7]+
integer                         {decimal_integer}|{hex_integer}|{octal_integer}
exponent                        (e|E)(\+|-)?[0-9]+
double                          {decimal_integer}?[.][0-9]+{exponent}?
identifier                      [_[:alpha:]][_[:alnum:]]*
single_line_comment             "//".*
multi_line_comment              "/*"([^*/]|[*][^/]|[^*].|{line_terminator})*[*]?"*/"

%%

{multi_line_comment}                            { yylloc->step(); }
{single_line_comment}                           { yylloc->step(); }
{spaces}                                        { yylloc->step(); }
{line_terminator}                               { yylloc->step(); }
{integer}                                       {
                                                    yylval->var = yytext;
                                                    return compiler::parser::n_syntax::token::integer_token;
                                                }
{double}                                        {
                                                    yylval->var = yytext;
                                                    return compiler::parser::n_syntax::token::double_token;
                                                }

else                                            return compiler::parser::n_syntax::token::else_token;
false                                           return compiler::parser::n_syntax::token::false_token;
if                                              return compiler::parser::n_syntax::token::if_token;
return                                          return compiler::parser::n_syntax::token::return_token;
true                                            return compiler::parser::n_syntax::token::true_token;
while                                           return compiler::parser::n_syntax::token::while_token;

{identifier}                                    {
                                                    yylval->var = yytext;
                                                    return compiler::parser::n_syntax::token::identifier;
                                                }

==                                              return compiler::parser::n_syntax::token::equal_token;
>=                                              return compiler::parser::n_syntax::token::greater_equal_token;
~[/]                                            return compiler::parser::n_syntax::token::int_div_token;
[<]=                                            return compiler::parser::n_syntax::token::less_equal_token;
&&                                              return compiler::parser::n_syntax::token::logical_and_token;
[|][|]                                          return compiler::parser::n_syntax::token::logical_or_token;
^^                                              return compiler::parser::n_syntax::token::logical_xor_token;
!=                                              return compiler::parser::n_syntax::token::not_equal_token;
->                                              return compiler::parser::n_syntax::token::right_arrow_token;
[.;,<>+\-\[\]*%&|\^!~?:={}()/]                  return compiler::parser::n_syntax::token_type(*yytext);

.                                               return compiler::parser::n_syntax::token_type(*yytext);

%%

//CLOSE_NAMESPACE
