#ifndef COMPILER_AST_NODE_HEADER
#define COMPILER_AST_NODE_HEADER

namespace compiler { namespace ast {

class node
{
    node(const node&);
    node& operator= (const node&);

public:
    node() {}
    virtual ~node() {}
};

}}

#endif