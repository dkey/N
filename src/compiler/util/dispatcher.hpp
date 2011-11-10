#ifndef COMPILER_UTIL_DISPATCHER_HEADER
#define COMPILER_UTIL_DISPATCHER_HEADER

#include <functional>
#include <stdexcept>
#include "boost/unordered_map.hpp"
#include "hierarchy_node.hpp"

namespace compiler { namespace util {

class method_not_found : public std::exception
{
public:
    virtual const char* what() const throw()
    {
        return "Method not found";
    }
};

class method_already_exists : public std::exception
{
public:
    virtual const char* what() const throw()
    {
        return "Method already exists";
    }
};

template<class T>
class dispatcher;

template<class BaseResult, class BaseLhs, class BaseRhs>
class dispatcher<BaseResult (BaseLhs, BaseRhs)>
{
    static hierarchy_node *lhs_root, *rhs_root;

    typedef std::pair<hierarchy_node*, hierarchy_node*> key_type;
    typedef std::function<BaseResult (BaseLhs&, BaseRhs&)> function_type;
    typedef boost::unordered_map<key_type, function_type> map_type;
    typedef typename map_type::value_type value_type;

    map_type function_map;

    template<class Lhs, class Rhs>
    void append_method(function_type&& func)
    {
        key_type key(Lhs::get_hierarchy_node_static(),
                     Rhs::get_hierarchy_node_static());
        if(!function_map.emplace(key, std::move(func)).second)
            throw method_not_found();
    }

public:
    template<class Lhs, class Rhs, class Function>
    void append(Function func)
    {
        append_method<Lhs, Rhs>(function_type(
            [func] (BaseLhs& lhs, BaseRhs& rhs) -> BaseResult
            {
                return func(static_cast<Lhs&>(lhs),
                            static_cast<Rhs&>(rhs));
            }));
    }

    template<class Result, class Lhs, class Rhs>
    void append(std::function<Result (Lhs&, Rhs&)> func)
    {
        append<Lhs, Rhs>(std::move(func));
    }

    template<class Result, class Lhs, class Rhs>
    void append(Result (*func)(Lhs&, Rhs&))
    {
        append<Lhs, Rhs>(func);
    }

    template<class Result, class Lhs, class Rhs>
    void append(Result (Lhs::*func)(Rhs&))
    {
        append_method<Lhs, Rhs>(function_type(
            [func] (BaseLhs& lhs, BaseRhs& rhs) -> BaseResult
            {
                return (static_cast<Lhs&>(lhs).*func)(static_cast<Rhs&>(rhs));
            }));
    }

    template<class Result, class Lhs, class Rhs>
    void append(Result (Lhs::*func)(Rhs&) const)
    {
        append_method<Lhs, Rhs>(function_type(
            [func] (BaseLhs& lhs, BaseRhs& rhs) -> BaseResult
            {
                return (static_cast<Lhs&>(lhs).*func)(static_cast<Rhs&>(rhs));
            }));
    }

    template<class Lhs, class Rhs>
    void remove()
    {
        key_type key(Lhs::get_hierarchy_node_static(),
                     Rhs::get_hierarchy_node_static());
        if(function_map.erase(key) == 0)
            throw method_not_found();
    }

    BaseResult operator() (BaseLhs& lhs, BaseRhs& rhs) const
    {
        auto iter = function_map.find(key_type(lhs.get_hierarchy_node(), rhs.get_hierarchy_node()));
        if(iter == function_map.cend())
            throw method_not_found();
        return iter->second(lhs, rhs);
    }
};

template<class Result, class BaseLhs, class BaseRhs>
hierarchy_node*
dispatcher<Result (BaseLhs, BaseRhs)>::lhs_root(BaseLhs::get_hierarchy_node_static());

template<class Result, class BaseLhs, class BaseRhs>
hierarchy_node*
dispatcher<Result (BaseLhs, BaseRhs)>::rhs_root(BaseRhs::get_hierarchy_node_static());

}}

#endif