package local.paas.mylab;

import javax.servlet.*;
import java.util.*;
import java.util.concurrent.*;
import java.net.*;
import javax.net.ssl.*;
import java.io.*;

public class ExternalCallerListener implements ServletContextListener {
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        String targetUrl = ctx.getInitParameter("target.url");
        boolean insecure = Boolean.parseBoolean(ctx.getInitParameter("insecure"));
        int interval = Integer.parseInt(ctx.getInitParameter("interval.seconds"));

        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println("Calling: " + targetUrl);
                if (insecure) {
                    trustAllHosts();
                }
                URL url = new URL(targetUrl);
                HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
                if (insecure) {
                    conn.setHostnameVerifier((s, session) -> true);
                }
                conn.setRequestMethod("GET");
                /* print content */
                /*
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder content = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine).append("\n");
                }
                in.close();
                System.out.println("Response: " + content.toString());
                */

                /* print response code */
                int responseCode = conn.getResponseCode();
                System.out.println("Response code: " + responseCode);

            } catch (Exception e) {
                System.err.println("Error calling external service: " + e.getMessage());
                e.printStackTrace();
            }
        }, 0, interval, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }

    private void trustAllHosts() throws Exception {
        TrustManager[] trustAllCerts = new TrustManager[] {
            new X509TrustManager() {
                public java.security.cert.X509Certificate[] getAcceptedIssuers() { return null; }
                public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType) { }
                public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType) { }
            }
        };
        SSLContext sc = SSLContext.getInstance("SSL");
        sc.init(null, trustAllCerts, new java.security.SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
    }
}
