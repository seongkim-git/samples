<%@ page import="java.util.*" %>
<%@ page import="io.opentracing.*, io.opentracing.util.GlobalTracer, io.opentracing.propagation.*, io.opentracing.SpanContext" %>
<%@ page import="local.paas.mylab.JaegerTracerBuilder, local.paas.mylab.HttpServletRequestExtractAdapter" %>

<%
    if (GlobalTracer.get().toString().contains("NoopTracer")) {
        Tracer tracer = JaegerTracerBuilder.init("app3");
        GlobalTracer.registerIfAbsent(tracer);
    }

    Tracer tracer = GlobalTracer.get();
    SpanContext parentCtx = tracer.extract(Format.Builtin.HTTP_HEADERS, new HttpServletRequestExtractAdapter(request));

    Span span;
    if (parentCtx != null) {
        span = tracer.buildSpan("app3-span").asChildOf(parentCtx).start();
    } else {
        span = tracer.buildSpan("app3-span").start();
    }

    span.setTag("component", "jsp");
    span.log("app3 span executed");
    System.out.println("[App3] traceId = " + span.context().toTraceId());
    span.finish();
%>
<html><body>
<h2>App3 처리 완료</h2>
<p>Trace 정보는 Jaeger에서 확인 가능</p>
</body></html>
