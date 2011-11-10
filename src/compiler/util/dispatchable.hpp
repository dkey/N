#ifndef COMPILER_UTIL_DISPATCHABLE_HEADER
#define COMPILER_UTIL_DISPATCHABLE_HEADER

#include "hierarchy_node.hpp"

#define HIERARCHY_NODE(Base)                                                                    \
    public:                                                                                     \
        static compiler::util::hierarchy_node* get_hierarchy_node_static()                      \
        {                                                                                       \
            static compiler::util::hierarchy_node node(Base::get_hierarchy_node_static());      \
            return &node;                                                                       \
        }                                                                                       \
        virtual compiler::util::hierarchy_node* get_hierarchy_node() const                      \
        {                                                                                       \
            return get_hierarchy_node_static();                                                 \
        }

#define HIERARCHY_ROOT                                                                          \
    public:                                                                                     \
        static compiler::util::hierarchy_node* get_hierarchy_node_static()                      \
        {                                                                                       \
            static compiler::util::hierarchy_node node;                                         \
            return &node;                                                                       \
        }                                                                                       \
        virtual compiler::util::hierarchy_node* get_hierarchy_node() const                      \
        {                                                                                       \
            return get_hierarchy_node_static();                                                 \
        }

#endif
