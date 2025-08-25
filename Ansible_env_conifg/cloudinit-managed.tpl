#cloud-config
packages:
  - python3
  - openssh-server

runcmd:
  # Create Ansible user
  - useradd -m ansible
  - mkdir -p /home/ansible/.ssh
  - echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
  - chown -R ansible:ansible /home/ansible/.ssh
  - chmod 700 /home/ansible/.ssh

  # Set hostname
  - hostnamectl set-hostname ${hostname}

  # Add Control Node's public key to authorized_keys
  - echo "${control_node_pubkey}" > /home/ansible/.ssh/authorized_keys
  - chown ansible:ansible /home/ansible/.ssh/authorized_keys
  - chmod 600 /home/ansible/.ssh/authorized_keys