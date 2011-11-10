#ifndef COMPILER_UTIL_HIERARCHY_NODE_HEADER
#define COMPILER_UTIL_HIERARCHY_NODE_HEADER

namespace compiler { namespace util {

class hierarchy_node
{
public:
    explicit hierarchy_node(hierarchy_node* parent = 0);
    hierarchy_node* parent() const;

private:
    hierarchy_node* parent_;
};

}}

#endif