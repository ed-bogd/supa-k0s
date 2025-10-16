#!/bin/bash

# Supabase Kubernetes Cleanup Script
# This script removes all Supabase resources from Kubernetes

set -e

echo "=================================================="
echo "   Cleaning up Supabase from Kubernetes"
echo "=================================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Confirmation prompt
read -p "⚠️  This will delete all Supabase resources including data. Continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo "🗑️  Removing Kubernetes resources..."
echo ""

# Delete in reverse order
# echo "1 Removing Kong API Gateway..."
# kubectl delete -f "${SCRIPT_DIR}/12-kong-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/11-kong-deployment.yaml" --ignore-not-found=true

# echo "2 Removing Auth (GoTrue)..."
# kubectl delete -f "${SCRIPT_DIR}/14-auth-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/13-auth-deployment.yaml" --ignore-not-found=true

# echo "3 Removing PostgREST..."
# kubectl delete -f "${SCRIPT_DIR}/16-rest-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/15-rest-deployment.yaml" --ignore-not-found=true

# echo "4 Removing Realtime..."
# kubectl delete -f "${SCRIPT_DIR}/18-realtime-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/17-realtime-deployment.yaml" --ignore-not-found=true

# echo "5 Removing Edge Functions..."
# kubectl delete -f "${SCRIPT_DIR}/20-functions-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/19-functions-deployment.yaml" --ignore-not-found=true

# echo "6 Removing Connection Pooler..."
# kubectl delete -f "${SCRIPT_DIR}/22-pooler-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/21-pooler-deployment.yaml" --ignore-not-found=true

# echo "7 Removing Studio (Dashboard)..."
# kubectl delete -f "${SCRIPT_DIR}/10-studio-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/09-studio-deployment.yaml" --ignore-not-found=true

# echo "8 Removing Postgres Meta..."
# kubectl delete -f "${SCRIPT_DIR}/08-meta-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/07-meta-deployment.yaml" --ignore-not-found=true

# echo "9 Removing PostgreSQL..."
# kubectl delete -f "${SCRIPT_DIR}/06-postgres-service.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/05-postgres-deployment.yaml" --ignore-not-found=true

# echo "10 Removing ConfigMaps..."
# kubectl delete -f "${SCRIPT_DIR}/04-configmap-functions.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/03-configmap-kong.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/02d-configmap-db-pooler.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/02c-configmap-db-realtime.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/02b-configmap-db-migrations.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/02-configmap-db-init.yaml" --ignore-not-found=true
# kubectl delete -f "${SCRIPT_DIR}/02a-configmap-db-pre-init.yaml" --ignore-not-found=true

# echo "10 Removing Secrets..."
# kubectl delete -f "${SCRIPT_DIR}/01-secrets.yaml" --ignore-not-found=true

echo "Removing Namespace..."
kubectl delete -f "${SCRIPT_DIR}/00-namespace/00-namespace.yaml" --ignore-not-found=true

echo ""
echo "✅ Cleanup complete! All Supabase resources removed."
