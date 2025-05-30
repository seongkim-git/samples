package local.paas.mylab;

import io.jaegertracing.Configuration;
import io.opentracing.Tracer;

public class JaegerTracerBuilder {
    public static Tracer init(String service) {
        Configuration.SamplerConfiguration samplerConfig = Configuration.SamplerConfiguration.fromEnv()
            .withType("const").withParam(1);

        Configuration.ReporterConfiguration reporterConfig = Configuration.ReporterConfiguration.fromEnv()
            .withLogSpans(true).withSender(Configuration.SenderConfiguration.fromEnv()
            .withAgentHost("jaeger-agent.jaeger.svc.cluster.local")
            .withAgentPort(6831));

        Configuration config = new Configuration(service)
            .withSampler(samplerConfig)
            .withReporter(reporterConfig);

        return config.getTracer();
    }
}
