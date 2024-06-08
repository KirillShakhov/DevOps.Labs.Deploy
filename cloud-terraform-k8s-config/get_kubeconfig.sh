yc managed-kubernetes cluster get-credentials --id catfhahhtsfqaor8o0v2 --external --kubeconfig ./kubeconfig

kubectl --kubeconfig=$(pwd)/kubeconfig get pods -n ingress-nginx