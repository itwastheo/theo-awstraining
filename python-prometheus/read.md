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
```
helm upgrade --install metrics prometheus-community/prometheus
```

# Install Grafana, this can be used to review the metrics
```
helm upgrade --install logging grafana/loki-stack \
  --namespace default --set promtail.enabled=true \
  --set grafana.enabled=true
```

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
kubectl port-forward svc/metrics-prometheus-server 8082:80 &
```
[View both metrics in Prometheus](http://localhost:8082/graph?g0.expr=kubelet_running_pods&g0.tab=1&g0.stacked=0&g0.range_input=1h&g1.expr=running_pods&g1.tab=1&g1.stacked=0&g1.range_input=1h&g2.expr=app_hello_world_total&g2.tab=0&g2.stacked=0&g2.range_input=1h). Follow the instructions below to inspect and test each metric.

### The `running_pods` metric

Assuming you opened the Prometheus server's UI (above), you should see that both metrics have the same value.

`kubelet_running_pods` is a built-in metric that you get out-of-the-box with Prometheus. It should have the same value as our custom `running_pods` metric.

Scale the Python app to go up by one:

```bash
kubectl scale deployment python-with-prometheus --replicas=2
```

Inspect `running_pods` and `kubelet_running_pods` to see the change in Prometheus.

### The `app_hello_world` metric

First, we have to make it possible to call the Python app.

Run this command:

```bash
# Port forward to the Python app
kubectl port-forward svc/slytherin-svc 5000:5000 &
```

Then, call the Python app's API however many times you like using `curl`:

```bash
# This will call our API and return "Hello, World!"
curl http://localhost:5000
```

Assuming you opened the Prometheus server's UI (above), you should see the count for `app_hello_world_total` go up however many times you called the API.

## How does Prometheus get the metric data for these counters?

Prometheus reads [text based metrics](https://prometheus.io/docs/instrumenting/exposition_formats/).

The text it actually ingests for this lab can be [viewed here, assuming you still have the port-forward setup on port 5000](http://localhost:5000/metrics). For background, the app is setup [serve Prometheus metrics here](https://github.com/kylos101/python-with-prometheus/blob/877e9cdf5d977cd6f5f955df1a6f62dd8d286f7b/app/app.py#L51).

Prometheus is installed with a Helm chart in this lab, and the chart supports annotations. Essentially, Prometheus will watch for pods that have these annotations, configure itself to use them, and then ingest their metrics.


First, we have to get access to grafana stack:
```
  kubectl get secret -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
  kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
Port-forward the Grafana service to access the Grafana UI:
```
kubectl --namespace default port-forward $POD_NAME 3000
```

**Step 6: Create a Dashboard in Grafana**
    -   Access Grafana UI in your browser: http://localhost:3000
    -   Log in to Grafana using the default credentials (admin/admin).

**Add Prometheus as a data source:**
    -   Click on "Configuration" in the side menu.
    -   Select "Data Sources" and click on "Add data source".
    -   Choose "Prometheus" as the type.
    -   Enter the Prometheus service URL (e.g., http://prometheus-server:80) and save the data source.
    -   Run the below command and copy the endpoints to retrieve the Prometheus Service URL
        ```
        kubectl describe svc metrics-prometheus-server
        ```
**Create a new dashboard:**

    -   Click on the "+" icon in the side menu and select "Dashboard" -> "Add new panel".
    -   Choose "Graph" as the visualization.
    -   Customize the visualization as needed (e.g., add labels, set a title).

