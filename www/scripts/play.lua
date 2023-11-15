http:content_type('text/html')

http:out('<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><title>Play</title></head>\n<body>\n')

objid=tonumber(args['id']) or 0
url=tostring(args['url']) or ''

http:out('<video id="video1" width="640" controls>\n')

if objid > 0 then
    http:out(string.format('<source src="/stream/%d.mp4" type="video/mp4">\n',objid))
elseif url ~= "" then
    http:out(string.format('<source src="%s" type="video/mp4">\n',url))
end

http:out('Your browser does not support HTML5 video.\n')

http:out('</video>\n')

http:out('<script>\n')

http:out('document.getElementById("video1").play();\n')

http:out('</script>\n')

http:out('</body></html>\n')
