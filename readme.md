# Learnings from argocd and kind
Trialling argocd to test self healing continuous delivery (CD) and "kind" for local K8s.


## Goals
1. Find any oddities with kind, compared with kubectl. Is kind config just set and forget? 
2. Build a "Hello World" argo-cd application set, get to grips with the toolset. Following Brad's guide.
3. Play around and understand the CD and Disaster Recovery (DR) options.
4. Trial DR
5. Spin up a more complex application for argocd to manage the deployments of.
6. Cheat Sheet

# 1. Is Kind kind to me?

Err... yep. So far no even minor hitch. I start the service, then use `kubectl` as normal.
Kind is a wrapper that allows one to run local K8s and use normal `kubectl` commands. 


# 2. Follow Brad's video on ArgoCD
Following along with the video, I built argo locally.
https://youtu.be/JLrR9RV9AFA

## Install prerequisites
If not already installed, install `git, go, docker, kind`.

## Installing latest/stable version of ArgoCD
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Forward Ports
Good to know for port mapping.
```
k get services -n argocd
kubectl port-forward service/argocd-server -n argocd 8080:443
```

### Get Credentials
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Install ArgoCD CLI / Login via CLI
```
brew install argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
argocd login 127.0.0.1:8080
```

### Creating an Application using ArgoCD CLI:
```
argocd app create webapp-kustom-prod \
--repo https://github.com/devopsjourney1/argo-examples.git \
--path kustom-webapp/overlays/prod --dest-server https://kubernetes.default.svc \
--dest-namespace prod
```
# 3. CD and DR
I am beginning to understand the different DR options.

# 4. Trial DR


# 6. Command Cheat sheet
Also good to know
```
argocd app create #Create a new Argo CD application.
argocd app list #List all applications in Argo CD.
argocd app logs <appname> #Get the application’s log output.
argocd app get <appname> #Get information about an Argo CD application.
argocd app diff <appname> #Compare the application’s configuration to its source repository.
argocd app sync <appname> #Synchronize the application with its source repository.
argocd app history <appname> #Get information about an Argo CD application.
argocd app rollback <appname> #Rollback to a previous version
argocd app set <appname> #Set the application’s configuration.
argocd app delete <appname> #Delete an Argo CD application.
```





