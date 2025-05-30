use log::info;
use proxy_wasm::traits::*;
use proxy_wasm::types::*;

proxy_wasm::main! {{
    proxy_wasm::set_log_level(LogLevel::Trace);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> { Box::new(HttpHeadersRoot) });
}}

struct HttpHeadersRoot;

impl Context for HttpHeadersRoot {}

impl RootContext for HttpHeadersRoot {
    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }

    fn create_http_context(&self, context_id: u32) -> Option<Box<dyn HttpContext>> {
        Some(Box::new(HttpHeaders { context_id }))
    }
}

struct HttpHeaders {
    context_id: u32,
}

impl Context for HttpHeaders {}

impl HttpContext for HttpHeaders {
    fn on_http_request_headers(&mut self, _: usize, _: bool) -> Action {
        // 요청 헤더 로깅
        for (name, value) in &self.get_http_request_headers() {
            info!("#{} -> {}: {}", self.context_id, name, value);
        }

        // uuid 헤더가 있을 경우 x-request-id로 복사
        if let Some(uuid) = self.get_http_request_header("uuid") {
            info!("#{} replacing x-request-id with uuid: {}", self.context_id, uuid);
            self.set_http_request_header("x-request-id", Some(&uuid));
        }

        Action::Continue
    }

    fn on_http_response_headers(&mut self, _: usize, _: bool) -> Action {
        for (name, value) in &self.get_http_response_headers() {
            info!("#{} <- {}: {}", self.context_id, name, value);
        }
        Action::Continue
    }

    fn on_log(&mut self) {
        info!("#{} completed.", self.context_id);
    }
}

