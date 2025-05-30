<%@ page import="java.util.*, java.io.*, java.net.*" %>
<%@ page import="io.opentracing.*, io.opentracing.propagation.*, io.opentracing.util.GlobalTracer" %>
<%@ page import="io.opentracing.SpanContext" %>
<%@ page import="local.paas.mylab.JaegerTracerBuilder, local.paas.mylab.HttpServletRequestExtractAdapter" %>

<%
    if (GlobalTracer.get().toString().contains("NoopTracer")) {
        Tracer tracer = JaegerTracerBuilder.init("app2");
        GlobalTracer.registerIfAbsent(tracer);
    }

    Tracer tracer = GlobalTracer.get();
    SpanContext parentCtx = tracer.extract(Format.Builtin.HTTP_HEADERS, new HttpServletRequestExtractAdapter(request));

    Span span;
    if (parentCtx != null) {
        span = tracer.buildSpan("app2-span").asChildOf(parentCtx).start();
    } else {
        span = tracer.buildSpan("app2-span").start();
    }

    span.setTag("component", "jsp");
    span.log("app2 span started");
    System.out.println("[App2] traceId = " + span.context().toTraceId());

    Span app3Span = tracer.buildSpan("call-app3").asChildOf(span).start();
    URL url = new URL("http://app3:8080/index.jsp");
    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("GET");

    Map<String, String> headers = new HashMap<>();
    tracer.inject(app3Span.context(), Format.Builtin.HTTP_HEADERS, new TextMapAdapter(headers));
    for (Map.Entry<String, String> entry : headers.entrySet()) {
        con.setRequestProperty(entry.getKey(), entry.getValue());
    }

    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
    String line;
    StringBuffer resp = new StringBuffer();
    while ((line = in.readLine()) != null) {
        resp.append(line).append("<br/>");
    }
    in.close();
    app3Span.finish();
    span.finish();
%>
<html><body>
<h2>App2 실행 완료</h2>
<pre><%= resp.toString() %></pre>
</body></html>
