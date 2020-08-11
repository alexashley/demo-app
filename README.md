# Demo App

## Overview

This repository is one example of how to deploy an application to Google Cloud Project (GCP).
It creates the infrastructure for that deployment using Terraform and the GCP provider;
specifically, it creates a Kubernetes cluster -- see the `tf/` directory for the implementation.

Manifests for the application are under the `manifest/` directory and are templated using Helm.
The Kubernetes deployment references a Docker image in Google Container Registry (GCR) that's built and pushed prior to deployment.

The repository is intended to be re-usable, as a whole or as a reference. 
There's some setup required, but the entirety of the deployment, including provisioning the infrastructure, is done in a single script.

## Prerequisites 

### Local Set-Up

This project makes certain assumptions about your local development environment. 
Mainly it expects that you're running on a *nix-based system like macOS or Ubuntu and that there's a recent version of these tools in your `$PATH`:

- [`gcloud`](https://cloud.google.com/sdk/gcloud)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [`docker`](https://www.docker.com/)
- [`jq`](https://stedolan.github.io/jq/)
- `make`

It also assumes that these `gcloud` authentication commands have been run: 
- `gcloud auth login`
- `gcloud auth application-default login`

:warning: The process of running this demo will add a `kubectl` context and set it as the current context.
    
### GCP Set-Up

This demo assumes that you have a GCP project with an associated billing account. 
See the [GCP docs](https://cloud.google.com/resource-manager/docs/creating-managing-projects) for how to set this up.

In addition, it assumes you're an owner of that project, or that you have these permissions:
- `serviceusage.services.*`
- `container.*`
- `storage.buckets.*`/`storage.objects.*`
- `resourcemanager.projects.get`/`resourcemanager.projects.list`

## Deployment

1. Export `PROJECT_ID` with your GCP project id
1. Run `./deploy.sh`

```
$ export PROJECT_ID=aha-demo-app
$ ./deploy.sh
```

Note: You can optionally pass a hostname to `deploy.sh` and it will set that on the ingress.
Once the application is deployed, you can update DNS to the load balancer IP, which will be output to the console as part of the deployment.

First, this script attempts to check that the necessary local tools are available and are configured correctly.
Next, it applies the Terraform, which will do the following
- Enable the GKE service
- Enable Stackdriver logging
- Enable GCR inside the project
- Create a new Kubernetes cluster and its node pool

After the Terraform has applied (this may take several minutes), 
the script will build a Docker image from the source code and push that to GCR.

Next, it authenticates to the Kubernetes cluster using the `gcloud` command.
Then it downloads the `nginx-ingress` Helm chart and stores that under `manifests/demo-app/charts`.
After that, it uses Helm to generate the Kubernetes manifests and pipes the result to `kubectl`.
The manifests configure a deployment that references the newly created Docker image, as well as a deployment of `nginx` to proxy traffic. 

Finally, the script outputs the logs of the post-deployment tests. 
The tests run twice -- once against the kubeDNS of the `demo-app` service and then once for whatever hostname was configured.
If you set a hostname different than the default, it's likely that the external tests will fail.
This is to be expected until the DNS record is updated. 
At which point you can run the tests again by doing the following:
```
$ kubectl -n demo-app delete pod demo-app-test
$ ./deploy.sh my-hostname.foo
```

## Cleaning Up

To remove all the GCP infrastructure, you can use the following command:

```
$ make tf-destroy
```

Note that this won't disable any enabled APIs or clean up any images in GCR. 
To completely clean everything up, you can delete the project. 
