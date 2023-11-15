/*
 * (c) 2023 Jack'lul <jacklulcat@gmail.com>
 */

#include "serialization.h"

serialization::data serialization::deserialize(const std::string& string)
{
    serialization::data data;
    data.deserialize(string);
    return data;
}
