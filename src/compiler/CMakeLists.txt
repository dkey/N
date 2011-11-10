project(n_compiler)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_CXX_FLAGS -std=c++0x)

find_package(Boost 1.47.0 REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)
BISON_TARGET(N_syntax parser/N.y ${n_compiler_BINARY_DIR}/n_syntax.cpp)
FLEX_TARGET(N_lexer parser/N.flex ${n_compiler_BINARY_DIR}/n_flex_lexer.cpp)
ADD_FLEX_BISON_DEPENDENCY(N_lexer N_syntax)

include_directories(${FLEX_INCLUDE_DIRS} ${PROJECT_BINARY_DIR} ${n_compiler_SOURCE_DIR})

add_executable(nc
    ${BISON_N_syntax_OUTPUTS}
    ${FLEX_N_lexer_OUTPUTS}
    main.cpp
    parser/n_lexer.cpp
    parser/n_parser.cpp
    util/hierarchy_node.cpp
)
