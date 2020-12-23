## Getting started
Clone repo:
```bash
git clone https://github.com/garethfuller/web-app-template.git <your-app-name> && cd <your-app-nam>
```

Run the setup script and follow the input instructions:
```bash
sh setup.sh
```

Once the setup script is complete, it will ask you to run:
```bash
docker-compose up
```

The app should now be accessible at [http://localhost:3000](http://localhost:3000)

## Deployment
Create a new file, `infra/secrets.yml`, and add any secrets required by the deployment.yml files.

Create the app namespace in your Kubernetes cluster:
```bash
kubectl apply -f infra/namespace
```

Setup the infrastructure in Kubernetes cluster:
```bash
kubectl apply -f infra
```

Add these three secrets to the web and api Github repos:

- DOCKER_ACCESS_TOKEN
- DOCKER_USERNAME
- KUBECONFIG

Ensure that the `KUBECONFIG` secret is a service account with deployment permissions. See the [/infra/access.yml](/infra/access.yml) file for details on the role binding.

Add DNS records for domains pointing to Kubernetes Ingress load balancer IP.

Push all changes to api and web repos, this will trigger deployments to K8s.
