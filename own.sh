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
echo "Creating namespace..."
kubectl apply -f "${SCRIPT_DIR}/00-namespace/00-namespace.yaml"

echo "Creating secrets..."
kubectl apply -f "${SCRIPT_DIR}/01-secrets/01-secrets.yaml"

echo "Creating DB..."
kubectl apply -f "${SCRIPT_DIR}/02-db/02a-configmap-db-pre-init.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02b-configmap-db-init.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02c-configmap-db-migrations.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02d-postgres-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/02-db/02e-postgres-service.yaml"
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n supabase --timeout=300s

# echo "Creating Logs..."
# echo "Analytics..."
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03a-logflare-analytics/03a-analytics-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03a-logflare-analytics/03b-analytics-service.yaml"
# echo "⏳ Waiting for Analytics to be ready..."
# kubectl wait --for=condition=ready pod -l app=analytics -n supabase --timeout=300s

# echo "Vector..."
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03c-vector-rbac.yaml"
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03d-configmap-vector.yaml"
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03e-vector-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/03-logs/03c-vector/03f-vector-service.yaml"
# echo "⏳ Waiting for Vector to start sending logs..."
# kubectl wait --for=condition=ready pod -l app=vector -n supabase --timeout=300s

echo "Deploying DB PostgREST..."
kubectl apply -f "${SCRIPT_DIR}/04-db-api/04a-meta-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/04-db-api/04b-meta-service.yaml"
echo "⏳ Waiting for Meta to be ready..."
kubectl wait --for=condition=ready pod -l app=meta -n supabase --timeout=300s

echo "Deploying Studio (Dashboard)..."
kubectl apply -f "${SCRIPT_DIR}/05-studio/05a-studio-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/05-studio/05b-studio-service.yaml"

# echo "Deploying Auth (GoTrue)..."
# kubectl apply -f "${SCRIPT_DIR}/06-auth/06a-auth-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/06-auth/06b-auth-service.yaml"

# echo "Deploying DB Realtime..."
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07a-configmap-db-realtime.yaml"
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07b-realtime-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07c-realtime-service.yaml"
# kubectl apply -f "${SCRIPT_DIR}/07-db-realtime/07d-create-realtime-user-job.yaml"

echo "Deploying DB Rest..."
kubectl apply -f "${SCRIPT_DIR}/08-db-rest/08a-rest-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/08-db-rest/08b-rest-service.yaml"

echo "Deploying API Gateway (Kong)..."
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09a-configmap-kong.yaml"
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09b-kong-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/09-api-gateway/09c-kong-service.yaml"

# echo "Deploying Connection Pooler (Supavisor)..."
# kubectl apply -f "${SCRIPT_DIR}/10-db-pooler/10a-configmap-db-pooler.yaml"
# kubectl apply -f "${SCRIPT_DIR}/10-db-pooler/10b-pooler-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/10-db-pooler/10c-pooler-service.yaml"

# echo "Deploying Edge Functions..."
# kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11a-configmap-functions.yaml"
# kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11b-functions-deployment.yaml"
# kubectl apply -f "${SCRIPT_DIR}/11-edge-functions/11c-functions-service.yaml"

echo "Deploying Storage..."
kubectl apply -f "${SCRIPT_DIR}/12-storage/storage-deployment.yaml"
kubectl apply -f "${SCRIPT_DIR}/12-storage/storage-service.yaml"

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
