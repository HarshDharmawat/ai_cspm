# app/app.py
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

class DummyInferenceHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # HAProxy relies on this exact endpoint returning a 200 status code
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "healthy", "gpu_active": false}')
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/summarize':
            # Mocking the AI summarization delay
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {"summary": "This is a mock ticket summary. The end-to-end routing works perfectly!"}
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def run(port=8000):
    server_address = ('0.0.0.0', port)
    httpd = HTTPServer(server_address, DummyInferenceHandler)
    print(f"Dummy Inference API running on port {port}...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()