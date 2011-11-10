#include "hierarchy_node.hpp"

namespace compiler { namespace util {

hierarchy_node::hierarchy_node(hierarchy_node* parent) :
    parent_(parent_)
{}

hierarchy_node* hierarchy_node::parent() const
{
    return parent_;
}

}}