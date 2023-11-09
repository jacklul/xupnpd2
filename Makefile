# sudo apt-get install uuid-dev libsqlite3-dev liblua5.3-dev libssl-dev

CXX      ?= g++
STRIP    ?= strip

CXXFLAGS ?= -fno-exceptions -fno-rtti
CPPFLAGS ?= -I. -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
LDLIBS   ?= -lm -ldl -luuid -lsqlite3 -llua5.3 -lssl -lcrypto
LDFLAGS  ?= -Wl,-E
UFLAGS   ?=

OBJS = main.o common.o charset.o compat.o db_sqlite.o http.o live.o luajson.o md5.o mime.o plugin_hls.o plugin_hls_common.o plugin_hls_new.o plugin_lua.o plugin_tsbuf.o plugin_tsfilter.o plugin_udprtp.o scan.o scripting.o soap.o soap_int.o ssdp.o ssl.o

all: version $(OBJS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(UFLAGS) -o xupnpd $(OBJS) $(LDLIBS) $(LDFLAGS)
	$(STRIP) xupnpd

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(UFLAGS) -o $@ $<

version:
	./ver.sh

clean:
	rm -f $(OBJS) version.h xupnpd xupnpd.db xupnpd.uid
