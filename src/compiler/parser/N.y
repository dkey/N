%skeleton "lalr1.cc"

%define parser_class_name "n_syntax"
%define namespace "compiler::parser"

%code requires
{
    namespace compiler { namespace ast { class program; }}
    class n_lexer;
}

%{
    #include <iostream>
    #include "parser/stype.hpp"
    #define YYSTYPE stype
    #include "n_syntax.hpp"
    #include "parser/n_lexer.hpp"
    #include "ast/statements.hpp"
    #include "location.hh"
    typedef compiler::parser::n_syntax parser_type;
    typedef parser_type::token_type token_type;
    typedef parser_type::semantic_type semantic_type;
    typedef parser_type::location_type location_type;

    token_type yylex(semantic_type* yylval, location_type* yylloc, n_lexer& lexer)
    {
        return token_type(lexer.yylex(yylloc, yylval));
    }
%}

%parse-param {ast::program*& tree}
%parse-param {n_lexer& lexer}
%lex-param   {n_lexer& lexer}

%locations

%right else_token

%token  END 0

%token  else_token
        false_token
        if_token
        return_token
        true_token
        while_token

%token  equal_token
        greater_equal_token
        int_div_token
        less_equal_token
        logical_and_token
        logical_or_token
        logical_xor_token
        not_equal_token
        right_arrow_token

%token  identifier
        integer_token
        double_token



%%


program:                                        source_element_list
                                                {
                                                    tree = new ast::program(boost::get<ast::source_element_list*>($1.var));
                                                }
;

primary_expression:                             identifier
                                                {
                                                    $$.var = new ast::identifier(boost::get<std::string>($1.var));
                                                }
|                                               boolean_literal
                                                {
                                                    $$.var = new ast::boolean_literal(boost::get<std::string>($1.var) == "true");
                                                }
|                                               integer_literal
                                                {
                                                    auto text = boost::get<std::string>($1.var);
                                                    $$.var = new ast::integer_literal(text);
                                                }
|                                               double_literal
                                                {
                                                    auto text = boost::get<std::string>($1.var);
                                                    $$.var = new ast::double_literal(text);
                                                }
|                                               '(' expression ')'
;

boolean_literal:                                true_token
|                                               false_token
;

integer_literal:                                integer_token
;

double_literal:                                 double_token
;

call_expression:                                primary_expression
|                                               call_expression '(' argument_list ')'
                                                {
                                                    $$.var = new ast::call_expression(
                                                                    boost::get<ast::expression*>($1.var),
                                                                    boost::get<ast::argument_list*>($3.var));
                                                }
;

argument_list:                                  /* empty */
                                                {
                                                    $$.var = new ast::argument_list();
                                                }
|                                               assignment_expression
                                                {
                                                    std::unique_ptr<ast::argument_list> ptr(new ast::argument_list());
                                                    ptr->args.push_back(boost::get<ast::expression*>($1.var));
                                                    $$.var = ptr.release();
                                                }
|                                               argument_list ',' assignment_expression
                                                {
                                                    auto expr = boost::get<ast::expression*>($3.var);
                                                    boost::get<ast::argument_list*>($$.var)->args.push_back(expr);
                                                }
;

left_hand_side_expression:                      call_expression
;

unary_expression:                               call_expression
|                                               '!' unary_expression
                                                {
                                                    auto expr = boost::get<ast::expression*>($2.var);
                                                    $$.var = new ast::unary_expression(expr, ast::unary_expression::logical_not_oper);
                                                }
|                                               '+' unary_expression
                                                {
                                                    auto expr = boost::get<ast::expression*>($2.var);
                                                    $$.var = new ast::unary_expression(expr, ast::unary_expression::plus_oper);
                                                }
|                                               '-' unary_expression
                                                {
                                                    auto expr = boost::get<ast::expression*>($2.var);
                                                    $$.var = new ast::unary_expression(expr, ast::unary_expression::minus_oper);
                                                }
;

multiplicative_expression:                      unary_expression
|                                               multiplicative_expression '*' unary_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::multiplication_oper);
                                                }
|                                               multiplicative_expression '/' unary_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::division_oper);
                                                }
|                                               multiplicative_expression '%' unary_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::mod_oper);
                                                }
|                                               multiplicative_expression int_div_token unary_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::int_division_oper);
                                                }
;

additive_expression:                            multiplicative_expression
|                                               additive_expression '+' multiplicative_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::plus_oper);
                                                }
|                                               additive_expression '-' multiplicative_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::minus_oper);
                                                }
;

relational_expression:                          additive_expression
|                                               relational_expression '>' additive_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::greater_oper);
                                                }
|                                               relational_expression '<' additive_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::less_oper);
                                                }
|                                               relational_expression greater_equal_token additive_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::greater_equal_oper);
                                                }
|                                               relational_expression less_equal_token additive_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::less_equal_oper);
                                                }
;

equality_expression:                            relational_expression
|                                               equality_expression equal_token relational_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::equal_oper);
                                                }
|                                               equality_expression not_equal_token relational_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::not_equal_oper);
                                                }
;

logical_and_expression:                         equality_expression
|                                               logical_and_expression logical_and_token equality_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::logical_and_oper);
                                                }
;

logical_xor_expression:                         logical_and_expression
|                                               logical_xor_expression logical_xor_token logical_and_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::logical_xor_oper);
                                                }
;

logical_or_expression:                          logical_xor_expression
|                                               logical_or_expression logical_or_token logical_xor_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::logical_or_oper);
                                                }
;

conditional_expression:                         logical_or_expression
|                                               logical_or_expression if_token assignment_expression else_token assignment_expression
                                                {
                                                    auto true_expr = boost::get<ast::expression*>($1.var),
                                                        condition = boost::get<ast::expression*>($3.var),
                                                        false_expr = boost::get<ast::expression*>($5.var);
                                                    $$.var = new ast::conditional_expression(condition, true_expr, false_expr);
                                                }
;

assignment_expression:                          conditional_expression
|                                               left_hand_side_expression '=' assignment_expression
                                                {
                                                    auto left = boost::get<ast::expression*>($1.var),
                                                        right = boost::get<ast::expression*>($3.var);
                                                    $$.var = new ast::binary_expression(left, right,
                                                                ast::binary_expression::assignment_oper);
                                                }
;

expression:                                     assignment_expression
;

statement:                                      block
|                                               empty_statement
|                                               expression_statement
|                                               while_statement
|                                               variable_statement
|                                               return_statement
;

block:                                          '{' '}'
                                                {
                                                    $$.var = new ast::block();
                                                }
|                                               '{' statement_list '}'
                                                {
                                                    $$.var = new ast::block(boost::get<ast::statement_list*>($2.var));
                                                }
;

expression_statement:                           expression ';'
                                                {
                                                    auto expr = boost::get<ast::expression*>($1.var);
                                                    $$.var = new ast::expression_statement(expr);
                                                }
;

empty_statement:                                ';'
                                                {
                                                    $$.var = new ast::statement();
                                                }
;

statement_list:                                 statement
                                                {
                                                    std::unique_ptr<ast::statement_list> lst(new ast::statement_list());
                                                    lst->statements.push_back(boost::get<ast::statement*>($1.var));
                                                    $$.var = lst.release();
                                                }
|                                               statement_list statement
                                                {
                                                    auto stmt = boost::get<ast::statement*>($2.var);
                                                    boost::get<ast::statement_list*>($$.var)->statements.push_back(stmt);
                                                }
;

while_statement:                                while_token '(' expression ')' statement
                                                {
                                                    auto expr = boost::get<ast::expression*>($3.var);
                                                    auto stmt = boost::get<ast::statement*>($5.var);
                                                    $$.var = new ast::while_statement(expr, stmt);
                                                }
;

return_statement:                               return_token expression ';'
                                                {
                                                    $$.var = new ast::return_statement(boost::get<ast::expression*>($2.var));
                                                }
;

variable_statement:                             type_identifier variable_declaration_list ';'
                                                {
                                                    $$.var = new ast::variable_statement(boost::get<std::string>($1.var),
                                                                    boost::get<ast::variable_declaration_list*>($2.var));
                                                }
;

variable_declaration_list:                      variable_declaration
                                                {
                                                    std::unique_ptr<ast::variable_declaration_list> lst(
                                                            new ast::variable_declaration_list());
                                                    lst->vars.push_back(boost::get<ast::variable_declaration*>($1.var));
                                                    $$.var = lst.release();
                                                }
|                                               variable_declaration_list ',' variable_declaration
                                                {
                                                    auto var = boost::get<ast::variable_declaration*>($3.var);
                                                    boost::get<ast::variable_declaration_list*>($$.var)->vars.push_back(var);
                                                }
;

variable_declaration:                           identifier
                                                {
                                                    $$.var = new ast::variable_declaration(boost::get<std::string>($1.var));
                                                }
|                                               identifier initializer
                                                {
                                                    $$.var = new ast::variable_declaration(boost::get<std::string>($1.var),
                                                                    boost::get<ast::expression*>($2.var));
                                                }
;

initializer:                                    '=' assignment_expression
                                                {
                                                    $$.var = $2.var;
                                                }
;

function_declaration:                           identifier '(' parameter_list ')' right_arrow_token type_identifier ';'
                                                {
                                                    auto name = boost::get<std::string>($1.var),
                                                        type = boost::get<std::string>($6.var);
                                                    auto params = boost::get<ast::parameter_list*>($3.var);
                                                    $$.var = new ast::function_declaration(name, type, params);
                                                }
;

function_definition:                            identifier '(' parameter_list ')' right_arrow_token type_identifier block
                                                {
                                                    auto name = boost::get<std::string>($1.var),
                                                        type = boost::get<std::string>($6.var);
                                                    auto params = boost::get<ast::parameter_list*>($3.var);
                                                    std::unique_ptr<ast::function_declaration> decl(
                                                        new ast::function_declaration(name, type, params));
                                                    $$.var = new ast::function_definition(decl.get(),
                                                                boost::get<ast::statement*>($7.var));
                                                    decl.release();
                                                }
;

type_identifier:                                identifier
;

parameter_list:                                 /* empty */
                                                {
                                                    $$.var = new ast::parameter_list();
                                                }
|                                               parameter
                                                {
                                                    std::unique_ptr<ast::parameter_list> lst(
                                                        new ast::parameter_list());
                                                    lst->params.push_back(boost::get<ast::parameter*>($1.var));
                                                    $$.var = lst.release();
                                                }
|                                               parameter_list ',' parameter
                                                {
                                                    auto param = boost::get<ast::parameter*>($3.var);
                                                    boost::get<ast::parameter_list*>($1.var)->params.push_back(param);
                                                }
;

parameter:                                      identifier identifier
                                                {
                                                    $$.var = new ast::parameter(boost::get<std::string>($1.var),
                                                                                boost::get<std::string>($2.var));
                                                }
;

source_element:                                 function_declaration
                                                {
                                                    $$.var = new ast::source_element(boost::get<ast::statement*>($1.var));
                                                }
|                                               function_definition
                                                {
                                                    $$.var = new ast::source_element(boost::get<ast::statement*>($1.var));
                                                }
|                                               variable_statement
                                                {
                                                    $$.var = new ast::source_element(boost::get<ast::statement*>($1.var));
                                                }
;

source_element_list:                            source_element
                                                {
                                                    std::unique_ptr<ast::source_element_list> lst(
                                                        new ast::source_element_list());
                                                    lst->childs.push_back(boost::get<ast::source_element*>($1.var));
                                                    $$.var = lst.release();
                                                }
|                                               source_element_list source_element
                                                {
                                                    auto element = boost::get<ast::source_element*>($2.var);
                                                    boost::get<ast::source_element_list*>($$.var)->childs.push_back(element);
                                                }
;





%%

void parser_type::error(const location_type&, const std::string& message)
{
    std::cout << message << std::endl;
}