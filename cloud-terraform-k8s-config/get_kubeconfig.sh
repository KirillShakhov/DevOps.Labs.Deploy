yc managed-kubernetes cluster get-credentials --id cato2invbqt1khmn3u6i --external --kubeconfig ./kubeconfig

kubectl --kubeconfig=$(pwd)/kubeconfig get pods -n ingress-nginx