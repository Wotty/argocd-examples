# Requires: kind, kubectl, argocd CLI
# kind delete cluster --name argocd 2>/dev/null || true # uncomment to delete any existing cluster first
kind create cluster --name argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml # install.yaml
# argocd initial admin password is the name of the server pod
echo "Waiting for ArgoCD server to be ready..."
kubectl rollout status "deployment/argocd-server" -n argocd --timeout=120s
echo " ✓ ArgoCD server is ready."
# Start ArgoCD port-forward silently
kubectl port-forward service/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
ARGOCD_PF=$!
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
echo $ARGOCD_PASS
# argocd login localhost:8080 --insecure --username admin --password $ARGOCD_PASS
kubectl create namespace dev
# Create the application using the Application manifest
kubectl apply -f argocd-apps/helm-webapp-dev.yaml
# Sync the application to deploy it
argocd app sync helm-webapp-dev
argocd app wait helm-webapp-dev --health --operation --timeout 120
echo " ✓ helm-webapp-dev has been deployed to the 'dev' namespace."
# Port-forward the helm app
kubectl port-forward service/helm-webapp-svc 8088:80 -n dev > /dev/null 2>&1 &
HELM_PF=$!

# Wait for user input to clean up including argoCD deployed applications
read -p "Press [Enter] to remove port-forwards and delete ArgoCD..."
# Delete all ArgoCD applications
argocd app list -o name | xargs -r argocd app delete --yes
# kill port forwarding
if kill -0 "$ARGOCD_PF" 2>/dev/null; then
    kill "$ARGOCD_PF" 2>/dev/null || true
    wait "$ARGOCD_PF" 2>/dev/null || true
fi
if kill -0 "$HELM_PF" 2>/dev/null; then
    kill "$HELM_PF" 2>/dev/null || true
    wait "$HELM_PF" 2>/dev/null || true
fi
sleep 2
# kind delete cluster --name argocd
echo "ArgoCD applications, ArgoCD, and port-forwards have been removed."