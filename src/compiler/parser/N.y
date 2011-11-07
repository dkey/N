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

    template<class T, class Variant>
    T&& move_get(Variant& var)
    {
        return std::move(boost::get<T>(var));
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
                                                    tree = new ast::program(std::move(boost::get<src_elem_list_ptr>($1.var)));
                                                }
;

primary_expression:                             identifier
                                                {
                                                    $$.var = expr_ptr(new ast::identifier(boost::get<std::string>($1.var)));
                                                }
|                                               boolean_literal
                                                {
                                                    $$.var = expr_ptr(new ast::boolean_literal(
                                                                        boost::get<std::string>($1.var) == "true"));
                                                }
|                                               integer_literal
                                                {
                                                    auto text = boost::get<std::string>($1.var);
                                                    $$.var = expr_ptr(new ast::integer_literal(text));
                                                }
|                                               double_literal
                                                {
                                                    auto text = boost::get<std::string>($1.var);
                                                    $$.var = expr_ptr(new ast::double_literal(text));
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
                                                    $$.var = expr_ptr(new ast::call_expression(
                                                                    move_get<expr_ptr>($1.var),
                                                                    move_get<arg_list_ptr>($3.var)));
                                                }
;

argument_list:                                  /* empty */
                                                {
                                                    $$.var = arg_list_ptr(new ast::argument_list());
                                                }
|                                               assignment_expression
                                                {
                                                    arg_list_ptr ptr(new ast::argument_list());
                                                    ptr->args.push_back(move_get<expr_ptr>($1.var));
                                                    $$.var = std::move(ptr);
                                                }
|                                               argument_list ',' assignment_expression
                                                {
                                                    auto expr = boost::get<expr_ptr>($3.var);
                                                    boost::get<arg_list_ptr>($$.var)->args.push_back(std::move(expr));
                                                }
;

left_hand_side_expression:                      call_expression
;

unary_expression:                               call_expression
|                                               '!' unary_expression
                                                {
                                                    auto expr = boost::get<expr_ptr>($2.var);
                                                    $$.var = expr_ptr(new ast::unary_expression(
                                                                std::move(expr), ast::unary_expression::logical_not_oper));
                                                }
|                                               '+' unary_expression
                                                {
                                                    auto expr = boost::get<expr_ptr>($2.var);
                                                    $$.var = expr_ptr(new ast::unary_expression(
                                                                std::move(expr), ast::unary_expression::plus_oper));
                                                }
|                                               '-' unary_expression
                                                {
                                                    auto expr = boost::get<expr_ptr>($2.var);
                                                    $$.var = expr_ptr(new ast::unary_expression(
                                                                std::move(expr), ast::unary_expression::minus_oper));
                                                }
;

multiplicative_expression:                      unary_expression
|                                               multiplicative_expression '*' unary_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::multiplication_oper));
                                                }
|                                               multiplicative_expression '/' unary_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::division_oper));
                                                }
|                                               multiplicative_expression '%' unary_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::mod_oper));
                                                }
|                                               multiplicative_expression int_div_token unary_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::int_division_oper));
                                                }
;

additive_expression:                            multiplicative_expression
|                                               additive_expression '+' multiplicative_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::plus_oper));
                                                }
|                                               additive_expression '-' multiplicative_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::minus_oper));
                                                }
;

relational_expression:                          additive_expression
|                                               relational_expression '>' additive_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::greater_oper));
                                                }
|                                               relational_expression '<' additive_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::less_oper));
                                                }
|                                               relational_expression greater_equal_token additive_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::greater_equal_oper));
                                                }
|                                               relational_expression less_equal_token additive_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::less_equal_oper));
                                                }
;

equality_expression:                            relational_expression
|                                               equality_expression equal_token relational_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::equal_oper));
                                                }
|                                               equality_expression not_equal_token relational_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::not_equal_oper));
                                                }
;

logical_and_expression:                         equality_expression
|                                               logical_and_expression logical_and_token equality_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::logical_and_oper));
                                                }
;

logical_xor_expression:                         logical_and_expression
|                                               logical_xor_expression logical_xor_token logical_and_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::logical_xor_oper));
                                                }
;

logical_or_expression:                          logical_xor_expression
|                                               logical_or_expression logical_or_token logical_xor_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::logical_or_oper));
                                                }
;

conditional_expression:                         logical_or_expression
|                                               logical_or_expression if_token assignment_expression else_token assignment_expression
                                                {
                                                    auto true_expr = boost::get<expr_ptr>($1.var),
                                                        condition = boost::get<expr_ptr>($3.var),
                                                        false_expr = boost::get<expr_ptr>($5.var);
                                                    $$.var = expr_ptr(new ast::conditional_expression(std::move(condition),
                                                                std::move(true_expr), std::move(false_expr)));
                                                }
;

assignment_expression:                          conditional_expression
|                                               left_hand_side_expression '=' assignment_expression
                                                {
                                                    auto left = boost::get<expr_ptr>($1.var),
                                                        right = boost::get<expr_ptr>($3.var);
                                                    $$.var = expr_ptr(new ast::binary_expression(std::move(left),
                                                                std::move(right), ast::binary_expression::assignment_oper));
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
                                                    $$.var = stmt_ptr(new ast::block());
                                                }
|                                               '{' statement_list '}'
                                                {
                                                    $$.var = stmt_ptr(new ast::block(move_get<stmt_list_ptr>($2.var)));
                                                }
;

expression_statement:                           expression ';'
                                                {
                                                    $$.var = stmt_ptr(new ast::expression_statement(
                                                                move_get<expr_ptr>($1.var)));
                                                }
;

empty_statement:                                ';'
                                                {
                                                    $$.var = stmt_ptr(new ast::statement());
                                                }
;

statement_list:                                 statement
                                                {
                                                    stmt_list_ptr lst(new ast::statement_list());
                                                    lst->statements.push_back(move_get<stmt_ptr>($1.var));
                                                    $$.var = std::move(lst);
                                                }
|                                               statement_list statement
                                                {
                                                    auto stmt = boost::get<stmt_ptr>($2.var);
                                                    boost::get<stmt_list_ptr>($$.var)->statements.push_back(std::move(stmt));
                                                }
;

while_statement:                                while_token '(' expression ')' statement
                                                {
                                                    auto expr = boost::get<expr_ptr>($3.var);
                                                    auto stmt = boost::get<stmt_ptr>($5.var);
                                                    $$.var = stmt_ptr(new ast::while_statement(std::move(expr), std::move(stmt)));
                                                }
;

return_statement:                               return_token expression ';'
                                                {
                                                    $$.var = stmt_ptr(new ast::return_statement(move_get<expr_ptr>($2.var)));
                                                }
;

variable_statement:                             type_identifier variable_declaration_list ';'
                                                {
                                                    $$.var = stmt_ptr(new ast::variable_statement(
                                                                    move_get<std::string>($1.var),
                                                                    move_get<var_decl_list_ptr>($2.var)));
                                                }
;

variable_declaration_list:                      variable_declaration
                                                {
                                                    var_decl_list_ptr lst(new ast::variable_declaration_list());
                                                    lst->vars.push_back(move_get<var_decl_ptr>($1.var));
                                                    $$.var = std::move(lst);
                                                }
|                                               variable_declaration_list ',' variable_declaration
                                                {
                                                    auto var = boost::get<var_decl_ptr>($3.var);
                                                    boost::get<var_decl_list_ptr>($$.var)->vars.push_back(std::move(var));
                                                }
;

variable_declaration:                           identifier
                                                {
                                                    $$.var = var_decl_ptr(new ast::variable_declaration(
                                                                move_get<std::string>($1.var)));
                                                }
|                                               identifier initializer
                                                {
                                                    $$.var = var_decl_ptr(new ast::variable_declaration(
                                                                    move_get<std::string>($1.var),
                                                                    move_get<expr_ptr>($2.var)));
                                                }
;

initializer:                                    '=' assignment_expression
                                                {
                                                    $$.var = move_get<expr_ptr>($2.var);
                                                }
;

function_declaration:                           identifier '(' parameter_list ')' right_arrow_token type_identifier ';'
                                                {
                                                    auto name = boost::get<std::string>($1.var),
                                                        type = boost::get<std::string>($6.var);
                                                    auto params = boost::get<param_list_ptr>($3.var);
                                                    $$.var = stmt_ptr(new ast::function_declaration(name, type, std::move(params)));
                                                }
;

function_definition:                            identifier '(' parameter_list ')' right_arrow_token type_identifier block
                                                {
                                                    auto name = boost::get<std::string>($1.var),
                                                        type = boost::get<std::string>($6.var);
                                                    auto params = boost::get<param_list_ptr>($3.var);
                                                    ast::func_decl_ptr decl(new ast::function_declaration(name, type, std::move(params)));
                                                    $$.var = stmt_ptr(new ast::function_definition(std::move(decl),
                                                                move_get<stmt_ptr>($7.var)));
                                                }
;

type_identifier:                                identifier
;

parameter_list:                                 /* empty */
                                                {
                                                    $$.var = param_list_ptr(new ast::parameter_list());
                                                }
|                                               parameter
                                                {
                                                    param_list_ptr lst(new ast::parameter_list());
                                                    lst->params.push_back(move_get<param_ptr>($1.var));
                                                    $$.var = std::move(lst);
                                                }
|                                               parameter_list ',' parameter
                                                {
                                                    auto param = boost::get<param_ptr>($3.var);
                                                    boost::get<param_list_ptr>($1.var)->params.push_back(std::move(param));
                                                }
;

parameter:                                      identifier identifier
                                                {
                                                    $$.var = param_ptr(new ast::parameter(boost::get<std::string>($1.var),
                                                                                boost::get<std::string>($2.var)));
                                                }
;

source_element:                                 function_declaration
                                                {
                                                    $$.var = src_elem_ptr(new ast::source_element(move_get<stmt_ptr>($1.var)));
                                                }
|                                               function_definition
                                                {
                                                    $$.var = src_elem_ptr(new ast::source_element(move_get<stmt_ptr>($1.var)));
                                                }
|                                               variable_statement
                                                {
                                                    $$.var = src_elem_ptr(new ast::source_element(move_get<stmt_ptr>($1.var)));
                                                }
;

source_element_list:                            source_element
                                                {
                                                    src_elem_list_ptr lst(new ast::source_element_list());
                                                    lst->childs.push_back(move_get<src_elem_ptr>($1.var));
                                                    $$.var = std::move(lst);
                                                }
|                                               source_element_list source_element
                                                {
                                                    auto element = boost::get<src_elem_ptr>($2.var);
                                                    boost::get<src_elem_list_ptr>($$.var)->childs.push_back(std::move(element));
                                                }
;





%%

void parser_type::error(const location_type&, const std::string& message)
{
    std::cout << message << std::endl;
}