###############################################################################
# TO WRITE -- Task 1, Criterion 1.   Stage 1 on Azure.
#
# Write this file ONLY if you chose Azure. Delete the two directories for the
# clouds you did not choose before you submit.
#
# provider.tf, variables.tf and outputs.tf are supplied. The variables are the
# inputs your stack must accept; the outputs are the contract it must satisfy.
#
# READ FIRST: docs/CLOUD-CONTRACT.md, then RUNBOOK.md section 0 -- the
# subscription pre-flight. Five minutes there saves an afternoon here.
###############################################################################

# ---------------------------------------------------------------------------
# WHAT THIS FILE MUST BUILD
#
# The contract, restated. Each line is worth marks in Criterion 1, and each is
# a question in the code defense.
#
#   1. A VM running Ubuntu 22.04 with 2 vCPU and 8 GiB. Smaller will not do:
#      kube-prometheus-stack alone wants 2-3 GiB before your application
#      starts, and a 4 GiB node presents the shortfall as random Evicted and
#      CrashLoopBackOff Pods that look exactly like application bugs.
#
#   2. A stable public address that survives deallocation. On Azure that
#      means choosing the right allocation method -- the default is not it.
#      Your hostname goes into a TLS certificate in Task 5.
#
#   3. A resolvable public hostname. Azure gives you one free; see below.
#
#   4. A firewall allowing 22, 80 and 443, and nothing else. Port 22 from your
#      own address only. Note what is NOT on that list: the Kubernetes API on
#      16443, Prometheus on 9090 and Grafana on 3000 are all closed, and you
#      reach them over an SSH tunnel. Be ready to explain why.
#
#      Azure network security groups deny inbound by default, so there is no
#      deny rule for you to write. Say so in your report rather than adding a
#      redundant one -- knowing which rules are unnecessary is the point.
#
#   5. A dedicated managed disk, separate from the OS disk. See THE /mnt TRAP.
#
#   6. SSH key authentication, with password authentication explicitly
#      disabled. The azurerm VM resource has a flag for this; set it.
#
#   7. A purpose-built virtual network rather than anything pre-existing.
#
# A VM on Azure needs more objects than a VM on AWS: the network interface is
# a resource of its own, and the public address attaches to the interface
# rather than to the machine. Work out the full set before you apply.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE HOSTNAME -- free, and the reason many people pick Azure
#
# Give the public IP a DNS label and Azure publishes
#
#   <label>.<region>.cloudapp.azure.com
#
# as a real, globally resolvable record at no cost. Expose it through a
# `locals` value named shop_host, which outputs.tf expects.
#
# The label must be unique within the region, so build it from var.dns_label
# and keep that specific to you. A clash fails the apply with a message that
# does not obviously say "someone else took this name".
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE /mnt TRAP -- the single most expensive mistake on Azure
#
# Azure attaches a *temporary* disk to most VM sizes, and Ubuntu images mount
# it at /mnt. It is fast, it is free, it looks like exactly the right place
# for container storage, and its contents are destroyed whenever the VM is
# deallocated, resized, or serviced onto another host.
#
# PersistentVolumes placed there vanish silently. You would discover it in
# Task 8, at the point where you deliberately delete the Redis Pod and find
# that the orders are gone for a reason you did not intend to demonstrate.
#
# The supplied bootstrap mounts your *managed* data disk at /datadisk, on
# every cloud, and points MicroK8s hostpath-storage there. Do not override
# that. After the VM boots, confirm it:
#
#   lsblk
#   df -h /datadisk
#   findmnt /datadisk      # must be your managed disk, not the temp disk
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE BOOTSTRAP -- do not write your own
#
# terraform/shared/cloud-init.yaml is supplied and is identical on all three
# clouds. Pass it via templatefile() with exactly two variables;
# CLOUD-CONTRACT.md gives the call.
#
# Two Azure specifics:
#
#   * The azurerm VM resource expects custom_data to be base64-encoded.
#     Terraform has a function for that. Forget it and cloud-init silently
#     does nothing: the VM boots perfectly and has no Kubernetes on it.
#
#   * For disk_hint, Azure publishes a stable udev symlink for a disk
#     attached at a given LUN. Find it and pass that rather than guessing
#     /dev/sdc, which works until the day it does not.
#
#   * admin_user on Azure is not `ubuntu`. Whatever you set as the VM's admin
#     username must be the value you pass here, or the kubeconfig is written
#     to a home directory that does not exist.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# STUDENT SUBSCRIPTION CONSTRAINTS
#
#   * Quota is the binding constraint -- commonly around 4 vCPU in total,
#     which a 2 vCPU VM fits with room for nothing else.
#
#   * An Allowed Locations policy restricts your regions and varies per
#     student. Check before you choose, not after the apply fails.
#
#   * Not every VM size is available to you. A size that exists in the region
#     may still be refused for your subscription.
#
#   * Your resource group may already exist with creation blocked. That is
#     what var.create_resource_group is for -- set it false and pass the name
#     you were given.
#
#   * provider.tf sets resource_provider_registrations = "none" because
#     student accounts often cannot register providers. If an apply still
#     fails on registration, see the note in that file.
#
# RUNBOOK.md section 0 has the az commands that answer all five.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# BEFORE YOU APPLY
#
#   az login && az account show -o table   # the right subscription?
#   ssh-keygen -t rsa -b 4096 -f k8s-key -N ''
#   terraform init && terraform fmt -check && terraform validate
#   terraform plan -var="username=<you>" -var="dns_label=<you>-shop" \
#                  -var="ssh_source_cidr=$(curl -s ifconfig.me)/32"
#
# Read the plan. Check the NSG rules are the three you intend before you
# create them. Commit as you go.
# ---------------------------------------------------------------------------
