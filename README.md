# xupnpd2

This is a fork of [xupnpd2](https://github.com/clark15b/xupnpd2) with extended functionality.

#### Latest binaries can be downloaded [from here](https://jacklul.github.io/xupnpd2/).

You will need these packages to run non-static variants:
```bash
sudo apt-get install uuid libsqlite3 liblua5.3 libssl
```

### List of changes
- **General**
    - Added config variables to define paths that were previously hardcoded:
        - `lua_script` - LUA script to use
        - `uuid_file` - UUID file to save generated UUID to (only when `upnp_device_uuid` is not set)
- **HTTP**
    - Added SSL support through [OpenSSL](https://www.openssl.org) library for client requests only
    - Support modification of `User-Agent` header through `http_user_agent` config variable
    - Correctly return 404 code for not found files and 403 for directories
- **SOAP**
    - Support remote logo links
    - Allow serving of the original stream URLs from the playlists (`upnp_raw_urls` config variable)
- **Scanning**
    - Include HTTPS links when scanning playlists
    - Support `tvg-logo` EXTINF attribute (`logo` has priority)
- **Building**
    - Created a single **Makefile** that uses system provided libraries
    - Removed included libraries from the repository
    - Include only required header files
