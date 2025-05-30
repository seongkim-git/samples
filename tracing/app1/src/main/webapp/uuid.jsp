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

    // UUID 헤더를 읽어와서 x-request-id로 복사
    String uuid = request.getHeader("uuid");
    Map<String, String> traceHeaders = new HashMap<>();
    if (uuid != null && !uuid.isEmpty()) {
        traceHeaders.put("x-request-id", uuid);
    }

    // 여기에 traceparent, tracestate 등도 필요하면 이어서 추가
    String[] passHeaders = {
        "traceparent", "tracestate", "uuid"
    };
    for (String h : passHeaders) {
        String val = request.getHeader(h);
        if (val != null) {
            traceHeaders.put(h, val);
        }
    }

    // 외부 호출 예시 (app2 호출)
    URL url = new URL("http://app2:8080/uuid.jsp");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");

    // 헤더 설정
    for (Map.Entry<String, String> entry : traceHeaders.entrySet()) {
        conn.setRequestProperty(entry.getKey(), entry.getValue());
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
