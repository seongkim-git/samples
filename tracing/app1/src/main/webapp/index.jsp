<%@ page import="java.util.*, java.io.*, java.net.*" %>

<%
    String path = request.getServletPath(); // 또는 getRequestURI()
    String filename = path.substring(path.lastIndexOf("/") + 1);
    System.out.println("=== APP1(" + filename + ") received headers ===");
    Enumeration<String> headerNames = request.getHeaderNames();
    while (headerNames.hasMoreElements()) {
        String name = headerNames.nextElement();
        String value = request.getHeader(name);
        System.out.println(name + ": " + value);
    }

    
    URL url = new URL("http://app2:8080/index.jsp");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");

    List<String> traceHeaders = Arrays.asList(
        "x-request-id", "x-b3-traceid", "x-b3-spanid", "x-b3-parentspanid",
        "x-b3-sampled", "x-b3-flags", "x-ot-span-context",
        "traceparent", "tracestate", "cookie", "authorization"
    );

    for (String h : traceHeaders) {
        String v = request.getHeader(h);
        if (v != null) {
            conn.setRequestProperty(h, v);
        }
    }

    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String line;
    StringBuffer sb = new StringBuffer();
    while ((line = in.readLine()) != null) {
        sb.append(line).append("\n");
    }
    in.close();
    System.out.println("[Response from child] " + sb.toString());
    
%>
<html><body>
<h2>APP1 처리 완료</h2>
<pre>Trace 연결은 Istio Sidecar가 담당하고, 이 JSP는 header 전파만 합니다.</pre>
</body></html>
