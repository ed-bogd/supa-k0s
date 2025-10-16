#!/bin/bash

# Supabase Kubernetes Deployment Script
# This script deploys a minimal Supabase setup with Dashboard and Database

set -e

echo "=================================================="
echo "   Deploying Supabase to Kubernetes"
echo "=================================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Applying Kubernetes manifests..."
echo ""

# Apply manifests in order
echo "================================="
echo "Creating namespace..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/00-namespace/00-namespace.yaml"

echo "================================="
echo "Creating secrets..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/01-secrets/01-secrets.yaml"

echo "================================="
echo "Creating DB..."
echo "================================="
# kubectl apply -f "${SCRIPT_DIR}/02-db/02a-configmap-db-pre-init.yaml"
# kubectl apply -f "${SCRIPT_DIR}/02-db/02b-configmap-db-init.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02c-configmap-db-migrations.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02d-postgres-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02e-postgres-service.yaml"
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n supabase --timeout=300s

echo "================================="
echo "Analytics..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/03-logs/03a-logflare-analytics/03a-analytics-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/03-logs/03a-logflare-analytics/03b-analytics-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/03-logs/03a-logflare-analytics/03c-analytics-service.yaml"
echo "⏳ Waiting for Analytics to be ready..."
kubectl wait --for=condition=ready pod -l app=analytics -n supabase --timeout=300s

echo "================================="
echo "Vector..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03c-vector-rbac.yaml"
kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03d-vector-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03e-vector-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03f-vector-service.yaml"
echo "⏳ Waiting for Vector to start sending logs..."
# kubectl wait --for=condition=ready pod -l app=vector -n supabase --timeout=300s

echo "================================="
echo "Deploying DB PostgREST..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/04-db-api/04a-meta-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/04-db-api/04b-meta-service.yaml"
echo "⏳ Waiting for Meta to be ready..."
kubectl wait --for=condition=ready pod -l app=meta -n supabase --timeout=300s

echo "================================="
echo "Deploying Studio (Dashboard)..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/05-studio/05a-studio-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/05-studio/05b-studio-service.yaml"

echo "================================="
echo "Deploying Auth (GoTrue)..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/06-auth/06a-auth-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/06-auth/06b-auth-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/06-auth/06c-auth-service.yaml"

echo "================================="
echo "Deploying DB Realtime..."
echo "================================="
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07a-configmap-db-realtime.yaml"
kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07b-realtime-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07c-realtime-service.yaml"
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07d-create-realtime-user-job.yaml"

echo "================================="
echo "Deploying DB Rest..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/08-db-rest/08c-rest-init-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/08-db-rest/08a-rest-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/08-db-rest/08b-rest-service.yaml"

echo "================================="
echo "Deploying API Gateway (Kong)..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09a-kong-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09b-kong-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09c-kong-service.yaml"

echo "================================="
echo "Deploying Connection Pooler (Supavisor)..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/10-db-supavisor/10a-supavisor-configmap.yaml"
kubectl apply -f "${SCRIPT_DIR}/10-db-supavisor/10b-supavisor-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/10-db-supavisor/10c-supavisor-service.yaml"

echo "================================="
echo "Deploying Edge Functions..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11a-configmap-functions.yaml"
kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11b-functions-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11c-functions-service.yaml"

echo "================================="
echo "Deploying Storage..."
echo "================================="
kubectl apply -f "${SCRIPT_DIR}/12-storage/12a-storage-api/12a-storage-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/12-storage/12b-storage-api/12b-storage-service.yaml"

# echo "---"
# echo "Running Jobs..."
# echo "Analytics..."
# kubectl apply -f "${SCRIPT_DIR}/99-jobs/logflare-analytics/99a-configmap-analytics-setup.yaml"
# kubectl apply -f "${SCRIPT_DIR}/99-jobs/logflare-analytics/99b-analytics-setup-job.yaml"
# echo "Restarting Logs..."
# kubectl rollout restart deployment/vector -n supabase
# kubectl rollout restart deployment/analytics -n supabase
# kubectl rollout restart deployment/kong -n supabase

# echo "---"
# echo "✅ Deployment complete!"
# echo ""
# echo "=================================================="
# echo "   Access Information"
# echo "=================================================="
# echo ""

# # Get NodePort
# KONG_PORT=$(kubectl get svc kong -n supabase -o jsonpath='{.spec.ports[0].nodePort}')

# echo "🌐 Supabase Studio Dashboard:"
# echo "   URL: http://localhost:${KONG_PORT}"
# echo "   Username: supabase"
# echo "   Password: supabase"
# echo ""
# echo "📊 Check deployment status:"
# echo "   kubectl get pods -n supabase"
# echo ""
# echo "📝 View logs:"
# echo "   kubectl logs -n supabase -l app=studio"
# echo "   kubectl logs -n supabase -l app=postgres"
# echo "   kubectl logs -n supabase -l app=kong"
# echo ""
# echo "🔧 Port forwarding (alternative access):"
# echo "   kubectl port-forward -n supabase svc/kong 8000:8000"
# echo ""
# echo "=================================================="
