#!/usr/bin/env bash
set -euo pipefail

echo "=== Nodes ==="
kubectl get nodes -o wide

echo "=== PAYTECH workloads ==="
kubectl get pods -n frontend -o wide
kubectl get pods -n backend -o wide
kubectl get pods -n database -o wide

echo "=== RBAC checks ==="
kubectl auth can-i list pods --as=system:serviceaccount:frontend:developer -n frontend || true
kubectl auth can-i delete pods --as=system:serviceaccount:frontend:developer -n frontend || true
kubectl auth can-i get secrets --as=system:serviceaccount:frontend:developer -n frontend || true

echo "=== NetworkPolicies ==="
kubectl get networkpolicies -A

echo "=== Resource controls ==="
kubectl get resourcequota,limitrange -n frontend

echo "=== Pod Security labels ==="
kubectl get namespace frontend --show-labels

echo "=== Trivy config scan (if installed) ==="
if command -v trivy >/dev/null 2>&1; then
  trivy config .
else
  echo "Trivy non installé : ignorer le scan local."
fi
