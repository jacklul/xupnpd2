# xupnpd2

This is a fork of [xupnpd2](https://github.com/clark15b/xupnpd2) with extended functionality.

### Latest binaries can be downloaded [from here](https://jacklul.github.io/xupnpd2/).

**When migrating from the official build to this one you have to delete the database file.**

You will need these packages to run non-static variants:

```bash
sudo apt-get install uuid libsqlite3 liblua5.3 libssl
```

### List of changes

- **General**
    - Added config variables to define paths that were previously hardcoded:
        - `lua_script` - LUA script to use
        - `uuid_file` - UUID file to save generated UUID to (only when `upnp_device_uuid` is not set)
    - Added `upnp_raw_urls_exclude` config variable to exclude streams handled by set handlers from being served as raw URL (when `upnp_raw_urls=true`)
    - Handle correctly URLs that start with a slash (absolute address)
- **HTTP**
    - Added SSL support through [OpenSSL](https://www.openssl.org) library
    - Support modification of `User-Agent` header through `http_user_agent` config variable
    - Correctly return 404 code for not found files and 403 when trying to access directories directly
    - When specific stream is forced to use raw URL its stream link becomes a 302 redirect (when `upnp_raw_urls=true` or EXTINF attribute `raw=true`)
    - Return playlist file when opening `/stream/ID.m3u8` (or `/stream/ID.m3u`)
- **HLS**
    - Support AES-128 encrypted streams through `hlse` handler
    - Handle playlists which are not using uppercase formatting
- **SOAP**
    - Support remote logo links
    - Allow serving of the original stream URLs from the playlists (`upnp_raw_urls` config variable)
- **LUA**
    - An additional field `use_raw_url` is available in returned data by function `browse`
    - Added `parent` function to print parent ID of a given ID
    - Load `json` library in webserver scripts
- **Scanning**
    - Include HTTPS links when scanning playlists
    - Support `tvg-logo` EXTINF attribute (`logo` has priority)
    - A new field `raw` (`true/false`) is available for use in EXTINF attributes (overrides `upnp_raw_urls` setting)
- **Building**
    - Created a single **Makefile** that uses system provided libraries
    - Removed included libraries' source files from the repository
    - Include only required header files in the repository