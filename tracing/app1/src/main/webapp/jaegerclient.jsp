<%@ page import="java.util.*, java.io.*, java.net.*" %>
<%@ page import="io.opentracing.*, io.opentracing.propagation.*, io.opentracing.util.GlobalTracer" %>
<%@ page import="local.paas.mylab.JaegerTracerBuilder" %>

<%
    if (GlobalTracer.get().toString().contains("NoopTracer")) {
        Tracer tracer = JaegerTracerBuilder.init("app1");
        GlobalTracer.registerIfAbsent(tracer);
    }

    Tracer tracer = GlobalTracer.get();
    Span span = tracer.buildSpan("app1-span").start();
    span.setTag("component", "jsp");
    span.log("app1 span started");
    System.out.println("[App1] traceId = " + span.context().toTraceId());

    Span app2Span = tracer.buildSpan("call-app2").asChildOf(span).start();

    URL url = new URL("http://app2:8080/index.jsp");
    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("GET");

    Map<String, String> headers = new HashMap<>();
    tracer.inject(app2Span.context(), Format.Builtin.HTTP_HEADERS, new TextMapAdapter(headers));
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
    app2Span.finish();
    span.finish();
%>
<html><body>
<h2>App1 실행 완료</h2>
<pre><%= resp.toString() %></pre>
</body></html>
