from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    if flow.response and flow.response.content:
        flow.response.content = flow.response.content.replace(
            b"p.parentNode.insertBefore(s, p);",
            b"fetch('/' + perimeterxId + '/init.js');"
        )