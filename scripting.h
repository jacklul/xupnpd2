/*
 * Copyright (C) 2015-2018 Anton Burdinuk
 * clark15b@gmail.com
 * http://xupnpd.org
 */

#ifndef __SCRIPTING_H
#define __SCRIPTING_H

#include "http.h"
#include "db.h"
#include "mime.h"

extern "C"
{
#include <lua5.3/lua.h>
}

namespace scripting
{
    bool init(void);

    bool main(http::req& req,const std::string& filename);

    void done(void);

    void __handle_raw_urls(lua_State* L, const std::string* handler, const std::string* extra, std::string* url);

    void __insert_db_fields(lua_State* L, const db::object_t* obj);

    void __insert_mime_fields(lua_State* L, const mime::type_t* mime);
}

#endif
