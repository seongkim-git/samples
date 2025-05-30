package local.paas.mylab;

import io.opentracing.propagation.TextMap;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

public class HttpServletRequestExtractAdapter implements TextMap {
    private final HttpServletRequest request;

    public HttpServletRequestExtractAdapter(HttpServletRequest request) {
        this.request = request;
    }

    @Override
    public Iterator<Map.Entry<String, String>> iterator() {
        Map<String, String> headers = new HashMap<>();
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String key = headerNames.nextElement();
            String value = request.getHeader(key);
            headers.put(key, value);
        }
        return headers.entrySet().iterator();
    }

    @Override
    public void put(String key, String value) {
        throw new UnsupportedOperationException("HttpServletRequestExtractAdapter is read-only.");
    }
}
