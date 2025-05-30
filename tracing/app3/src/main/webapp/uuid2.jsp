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

    // 자식 호출 없음
%>
<html><body>
<h2>APP3 처리 완료</h2>
<pre>Trace 연결은 Istio Sidecar가 담당하고, 이 JSP는 header 전파만 합니다.</pre>
</body></html>
