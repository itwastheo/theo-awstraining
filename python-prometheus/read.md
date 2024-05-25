**Using Prometheus and Grafana to monitor a Simple Python App**

# Spin up your Kubernetes Cluster**
```
eksctl create cluster --name dev --region us-east-1 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4 --managed
```
# Verify that you can connect to the cluster you created
```
aws eks update-kubeconfig --region us-east-1 --name dev
kubectl get nodes
```
# Set up OIDC to install Prometheus on the cluster
```
$ eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

# Create Service Account and Attach the IAM Policy
```
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster dev \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve
```

# Add the EBS CSI Driver:
```
eksctl create addon --name aws-ebs-csi-driver --cluster dev --service-account-role-arn arn:aws:iam::<account-ID>:role/AmazonEKS_EBS_CSI_DriverRole --force
```
# Verify the EBS CSI Driver 
```
$ eksctl get addon --name aws-ebs-csi-driver --cluster dev
```

# Setup helm repos to get software for your Kubernetes cluster
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

# Install Prometheus, later it'll scrape metrics from the Python app's pods
helm upgrade --install metrics prometheus-community/prometheus

# Install Loki-stack, this can be used to easily look at logs
helm upgrade --install logging grafana/loki-stack \
  --namespace default --set promtail.enabled=true \
  --set grafana.enabled=true 

**Get your Grafana password**
Get your 'admin' user password by running:

   kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
**Build and Push Docker Image**
```
docker build -t my-python-app .
```
Create a repo in ECR >> View Push commands and follow the steps.

**Tag the Docker Image:**
```
docker tag my-python-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com/my-ecr-repo:latest
```
**Authenticate Docker to the repo you have created in Amazon ECR:**
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com
```
**Push the Docker Image to Amazon ECR:**
```
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com/my-ecr-repo:latest
```
**Add the Python app to your Kubernetes cluster (EKS)**
Use the python-app-deployment.yaml file created previously to deploy your application to the EKS cluster:
```
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f rbac.yaml
```

**Step 5: Configure Prometheus to Scrape Metrics**
Now, let's configure Prometheus to scrape metrics from our Python application. We'll assume our Python application exposes metrics at the /metrics endpoint.

**Verify the Setup**
**Check Prometheus Targets:** Access the Prometheus UI and check the targets to ensure your application is being scraped.

Port-forward to access Prometheus UI:
```
kubectl port-forward svc/prometheus-operated 9090
```
**Check Metrics Endpoint:** Ensure your application exposes metrics correctly at the specified endpoint. You can access it directly to verify. 
```
kubectl port-forward svc/python-app 8080:80
```
Open your browser and go to http://localhost:8080/metrics.

**Step 6: Create a Dashboard in Grafana**
    -   Port-forward the Grafana service to access the Grafana UI:
    ```
    kubectl port-forward svc/grafana 3000:80
    ```
    -   Access Grafana UI in your browser: http://localhost:3000
    -   Log in to Grafana using the default credentials (admin/admin).

**Add Prometheus as a data source:**
    -   Click on "Configuration" in the side menu.
    -   Select "Data Sources" and click on "Add data source".
    -   Choose "Prometheus" as the type.
    -   Enter the Prometheus service URL (e.g., http://prometheus-server:80) and save the data source.
**Create a new dashboard:**

    -   Click on the "+" icon in the side menu and select "Dashboard" -> "Add new panel".
    -   Choose "Graph" as the visualization.
    -   In the "Query" section, enter a Prometheus query to visualize a metric from -   your Python application (e.g., python_requests_total).
    -   Customize the visualization as needed (e.g., add labels, set a title).

