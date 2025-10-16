#!/bin/bash

# Script to set up Supabase Storage database schema and permissions
# Run this after deploying the database and before starting Storage

POSTGRES_POD=$(kubectl get pods -n supabase -l app=postgres -o jsonpath='{.items[0].metadata.name}')

echo "Setting up Storage database..."

# Create storage schema
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_storage_admin;
"

# Create buckets table
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text UNIQUE NOT NULL,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
"

# Create objects table
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  bucket_id text REFERENCES storage.buckets(id),
  name text,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_accessed_at timestamptz DEFAULT now(),
  metadata jsonb,
  path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
  version text
);
"

# Grant permissions to service_role
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;
"

# Grant service_role to supabase_storage_admin
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
GRANT service_role TO supabase_storage_admin;
"

# Disable RLS on tables
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
"

# Set search_path for authenticator
kubectl exec -n supabase $POSTGRES_POD -- psql -U postgres -d postgres -c "
ALTER ROLE authenticator SET search_path TO public, storage, extensions;
"

echo "Storage database setup complete."