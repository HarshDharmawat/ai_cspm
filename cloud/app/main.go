package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)

type PageData struct {
	ServiceName string
	Environment string
	DBHost      string
	S3Bucket    string
	HostName    string
	CurrentTime string
}

const htmlTemplate = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PayVault Core Services</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 40px; }
        .container { max-width: 650px; margin: auto; background: #1e293b; padding: 30px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); border: 1px solid #334155; }
        h1 { color: #38bdf8; margin-top: 0; font-size: 24px; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 9999px; font-size: 12px; font-weight: 600; background: #065f46; color: #34d399; margin-bottom: 20px; }
        .card { background: #0f172a; border: 1px solid #334155; padding: 16px; border-radius: 8px; margin-bottom: 12px; }
        .label { color: #94a3b8; font-size: 12px; text-transform: uppercase; font-weight: bold; margin-bottom: 4px; }
        .value { font-family: monospace; font-size: 14px; color: #f1f5f9; }
    </style>
</head>
<body>
    <div class="container">
        <span class="badge">SYSTEM HEALTHY (VPC LINK ACTIVE)</span>
        <h1>💳 PayVault Invoicing Backend</h1>
        
        <div class="card">
            <div class="label">Host Node</div>
            <div class="value">{{.HostName}}</div>
        </div>
        <div class="card">
            <div class="label">Target Database Host</div>
            <div class="value">{{.DBHost}}</div>
        </div>
        <div class="card">
            <div class="label">Confidential Invoices Storage (S3)</div>
            <div class="value">{{.S3Bucket}}</div>
        </div>
        <div class="card">
            <div class="label">Server Timestamp</div>
            <div class="value">{{.CurrentTime}}</div>
        </div>
    </div>
</body>
</html>
`

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	hostname, _ := os.Hostname()
	dbHost := os.Getenv("DB_HOST")
	if dbHost == "" {
		dbHost = "10.0.1.20 (Default Internal)"
	}
	s3Bucket := os.Getenv("S3_BUCKET")
	if s3Bucket == "" {
		s3Bucket = "payvault-invoices-unassigned"
	}

	tmpl := template.Must(template.New("index").Parse(htmlTemplate))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data := PageData{
			ServiceName: "PayVault Transaction Router",
			Environment: "Production-Sandbox",
			DBHost:      dbHost,
			S3Bucket:    s3Bucket,
			HostName:    hostname,
			CurrentTime: time.Now().UTC().Format(time.RFC1123),
		}
		tmpl.Execute(w, data)
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"status":"UP","node":"%s"}`, hostname)
	})

	log.Printf("Starting PayVault engine on port :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
