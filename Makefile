# sudo apt-get install uuid-dev libsqlite3-dev liblua5.3-dev

CXX      ?= g++
STRIP    ?= strip

CXXFLAGS ?= -fno-exceptions -fno-rtti
CPPFLAGS ?= -I. -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
LDLIBS   ?= -lm -ldl -luuid -lsqlite3 -llua5.3
LDFLAGS  ?= -Wl,-E

OBJS = main.o common.o ssdp.o http.o soap.o soap_int.o db_sqlite.o scan.o mime.o charset.o scripting.o live.o md5.o luajson.o compat.o plugin_hls_common.o plugin_hls.o plugin_hls_new.o plugin_tsbuf.o plugin_lua.o plugin_udprtp.o plugin_tsfilter.o

all: version $(OBJS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o xupnpd $(OBJS) $(LDLIBS) $(LDFLAGS)
	$(STRIP) xupnpd

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $<

version:
	./ver.sh

clean:
	rm -f $(OBJS) version.h xupnpd xupnpd.db xupnpd.uid
