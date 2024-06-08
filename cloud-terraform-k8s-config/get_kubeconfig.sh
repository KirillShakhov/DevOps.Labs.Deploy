yc managed-kubernetes cluster get-credentials --id cato2invbqt1khmn3u6i --external --kubeconfig ./kubeconfig

kubectl --kubeconfig=$(pwd)/kubeconfig get pods -n ingress-nginx
kubectl --kubeconfig=$(pwd)/kubeconfig port-forward svc/argocd-server -n argocd 8080:443

kubectl --kubeconfig=$(pwd)/kubeconfig -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward service/grafana 3000:3000

kubectl port-forward service/grafana 3000:3000