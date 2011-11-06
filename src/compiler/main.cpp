#include <iostream>
#include <fstream>

#include "parser/n_parser.hpp"

int main(int argc, char* argv[])
{
    if(argc != 2)
        return 1;
    std::ifstream input(argv[1]);
    if(!input)
        return 2;
    compiler::parser::n_parser parser(input);
    std::cout << std::boolalpha << (parser.tree() != 0);
    return 0;
}