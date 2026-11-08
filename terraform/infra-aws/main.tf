###############################################################################
# TO WRITE -- Task 1, Criterion 1.   Stage 1 on AWS.
#
# Write this file ONLY if you chose AWS. Delete the two directories for the
# clouds you did not choose before you submit -- a repository containing three
# half-finished stacks is not a reproducible deployment.
#
# provider.tf, variables.tf and outputs.tf are supplied. The variables are the
# inputs your stack must accept; the outputs are the contract it must satisfy.
# Everything between the two is yours.
#
# READ FIRST: docs/CLOUD-CONTRACT.md -- the seven requirements this file has
# to meet, and why the boundary is where it is.
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
#      CrashLoopBackOff Pods that look exactly like application bugs. People
#      lose days to this.
#
#   2. A stable public address that survives a stop/start. Your hostname goes
#      into a TLS certificate in Task 5; an address that moves invalidates it.
#
#   3. A resolvable public hostname. AWS gives you no free DNS name, so derive
#      one -- see THE HOSTNAME below.
#
#   4. A firewall allowing 22, 80 and 443, and nothing else. Port 22 from your
#      own address only, not 0.0.0.0/0. Note what is NOT on that list: the
#      Kubernetes API on 16443, Prometheus on 9090 and Grafana on 3000 are all
#      closed, and you reach them over an SSH tunnel instead. Be ready to
#      explain why that is the right call.
#
#   5. A dedicated data disk, separate from the root volume. PersistentVolumes
#      live there.
#
#   6. SSH key authentication. Passwords are disabled by the base image;
#      do not re-enable them.
#
#   7. A purpose-built network rather than the default VPC. The default VPC
#      exists, and using it would work. Criterion 1 assesses network design,
#      and "I used the one that was already there" is not a design.
#
# Requirement 7 means more objects than you may expect. A subnet with no route
# to an internet gateway produces a VM that boots, accepts no connection, and
# gives you no error to read. Work out the full set before you apply.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE HOSTNAME
#
# Learner Lab gives you no Route 53 and no free DNS name. Use sslip.io, which
# resolves <anything>.<dashed-ip>.sslip.io straight back to that address with
# nothing to register:
#
#   13.55.2.9  ->  shop.13-55-2-9.sslip.io
#
# Build that string in a `locals` block from your address, as a value named
# shop_host -- outputs.tf expects it. Terraform's replace() does the dashes.
#
# Deriving it rather than typing it is the point: hardcode the hostname and
# your stack stops being reproducible the moment the address changes.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# THE BOOTSTRAP -- do not write your own
#
# terraform/shared/cloud-init.yaml is supplied and is identical on all three
# clouds. It finds the data disk, installs MicroK8s, enables the addons and
# writes a kubeconfig. Pass it as user_data via templatefile() with exactly
# two variables; CLOUD-CONTRACT.md gives the call.
#
# For disk_hint on AWS, note that the device name depends on the instance
# family -- Nitro instances present NVMe, older ones present /dev/xvdf. The
# script tries your hint first and then falls back, so a wrong hint costs you
# nothing. Passing "" is also valid.
#
# The script needs several minutes after terraform apply returns. Terraform
# reports success when AWS says the instance exists, which is not the same
# thing as the cluster being up. Watch /var/log/cloud-init-output.log and wait
# for /var/lib/cloud/bootstrap-complete.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# AWS ACADEMY LEARNER LAB -- constraints that are not in the AWS docs
#
#   * Credentials expire every few hours. A long apply can fail halfway with
#     an authentication error; refresh them from the console and re-run.
#     Terraform is idempotent, so re-running is safe -- that is one of the
#     arguments for using it, and worth making in your report.
#
#   * You cannot create IAM roles or instance profiles. Do not attach one.
#
#   * us-east-1 and us-west-2 only, and EBS volumes up to 100 GiB.
#
#   * Everything stops when the lab session ends. Budget your time, and run
#     `terraform destroy` yourself rather than relying on that.
#
#   * Find the AMI with a data source filtered on the Canonical owner ID and
#     an Ubuntu 22.04 name pattern. A hardcoded AMI ID is region-specific and
#     goes stale; both cost marks under reproducibility.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# BEFORE YOU APPLY
#
#   ssh-keygen -t rsa -b 4096 -f k8s-key -N ''   # this deployment only
#   terraform init
#   terraform fmt -check
#   terraform validate
#   terraform plan -var="username=<you>" \
#                  -var="ssh_source_cidr=$(curl -s ifconfig.me)/32"
#
# Read the plan. Check the security group rules are the three you intend
# before you create them, not after. Commit as you go: Criterion 1 assesses
# your workflow, and a single "final" commit is poor evidence of one.
# ---------------------------------------------------------------------------
