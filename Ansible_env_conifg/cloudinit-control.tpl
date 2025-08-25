#cloud-config
packages:
  - python3
  - sshpass
  - git
  - vim
  - openssh-client

runcmd:
  # Register with Red Hat Subscription Manager
  - subscription-manager register --username ${rhsm_username} --password ${rhsm_password} --auto-attach

  # Create Ansible user
  - useradd -m ansible
  - mkdir -p /home/ansible/.ssh
  - echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
  - chown -R ansible:ansible /home/ansible/.ssh
  - chmod 700 /home/ansible/.ssh

  # Generate SSH key for Ansible
  - sudo -u ansible ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""

  # Add managed nodes to /etc/hosts
  %{ for idx, ip in managed_nodes_ips ~}
  echo "${ip} managed-node-${idx}" >> /etc/hosts
  %{ endfor ~}

  # Create Ansible inventory
  - mkdir -p /home/ansible/ansible
  - echo "[workers]" > /home/ansible/ansible/inventory
  %{ for idx, ip in managed_nodes_ips ~}
  echo "managed-node-${idx} ansible_host=${ip} ansible_user=ansible" >> /home/ansible/ansible/inventory
  %{ endfor ~}
  - chown -R ansible:ansible /home/ansible/ansible