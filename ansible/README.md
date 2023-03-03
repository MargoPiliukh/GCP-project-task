# Deploy a VM in GCP

This playbook deploys a VM with the following specifications:

1. Machine family: c2-standard-8
2. OS: CentOS 7
3. Boot Disk: SSD persistent disk (200GB)

## Prerequisites:
- service account - json file available and specified in the `gcp_cred_file`
- project in GCP
- gcloud
- ansible
