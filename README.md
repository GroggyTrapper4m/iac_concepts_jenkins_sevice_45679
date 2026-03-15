# :computer: Jenkins in the Cloud :cloud:
The files contained in this repository is meant to serve as example code to get started with the industry standard IaC software tool, [Terraform](https://developer.hashicorp.com/terraform).

Everything is not completely managed in this repository example, namely due to the standard (e.g. HDD) file share IOPS, however the infrastructure layout has been broken up that allows for the storage to be initially created and later referenced.

However, I have provided a template in `data-layer` to potentially manage the storage through IaC later should it be deemed necessary.

The entire purpose of this repository is to be used as a learning tool for others consider what is here as a foundation specifically using the Microsoft Azure Infrastructure. 

---
###Background:
This template instantiates a [Azure Container App](https://azure.microsoft.com/en-us/products/container-apps) that pulls in the Jenkins image from Docker hub that is tied to Azure storage for the platform's data storage.
The idea behind this is that it uses cloud infrastructure to orchestrate storage, compute resources and improving the installation of configuration through plugins like the [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/) plugin that handle some of the tedious installation and updating. 

As mentioned above, this infrastructure in the `app-layer` requires a storage link, that is laid out in the `data-layer` folder, but not created through this script. Look through the `app-layer` template as well for `jenkins-volume-mount` should provide more information.


###Notes:
This also provides Jenkins scripts to load plugins upon initial startup. These plugins are contained within the `plugins.txt` file along with Jenkins scripts to install upon boot.

As mentioned above, this set up uses the standard storage tier which is a bit slower. I ended up connecting this to a SMB File Share within my Container app infrastructure. 

---
[More Information about Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview)


How to complete via Azure Cloud Shell:
<ol>
<li>Go to Azure Portal and Signin</li>
<li>Create a CLI request or go directly to the shell through [Azure CLI](http://shell.azure.com)</li>
<li>Wait for the shell to load up and add your SubID to your CLI instance.</li>
<li>From your home directory clone this repository ...</li>
<li>From `terraform-plans/app-layer/`~~~~~~~~~~ run the followings:</li>
<li>terraform init</li>
<li>terraform plan</li>
<li>If all looks well, go ahead and run terraform apply for Azure to create your container app.</li>
</ol>