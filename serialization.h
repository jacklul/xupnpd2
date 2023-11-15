/*
 * (c) 2023 Jack'lul <jacklulcat@gmail.com>
 */

#ifndef __SERIALIZATION_H
#define __SERIALIZATION_H

#include <string>
#include <unordered_map>
#include <sstream>
#include <algorithm>

namespace serialization
{
    struct data
    {
        std::unordered_map<std::string, std::string> data;

        std::string serialize() const
        {
            std::ostringstream oss;

            for (const auto& entry : data) {
                oss << entry.first << ":" << entry.second << '\n';
            }

            return oss.str();
        }

        void deserialize(const std::string& serializedData)
        {
            std::istringstream iss(serializedData);
            std::string line;

            while (std::getline(iss, line))
            {
                std::size_t separatorPos = line.find(':');

                if (separatorPos != std::string::npos)
                {
                    std::string key = line.substr(0, separatorPos);
                    std::string value = line.substr(separatorPos + 1);

                    if (validate_key(key) && validate_value(value))
                        data[key] = value;
                }
            }
        }

        void set(const std::string& key, const std::string& value)
        {
            if (validate_key(key) && validate_value(value))
                data[key] = value;
        }

        std::string get(const std::string& key) const
        {
            auto it = data.find(key);
            return (it != data.end()) ? it->second : "";
        }

        bool validate_key(const std::string& key) const
        {
            return std::all_of(key.begin(), key.end(), ::isalpha);
        }

        bool validate_value(const std::string& value) const
        {
            return value.find('\n') == std::string::npos;
        }
    };

    data deserialize(const std::string& string);
}

#endif
