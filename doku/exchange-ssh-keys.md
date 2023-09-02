# exchange ssh-keys

Let's say you have three nodes and want to get from each node to another without password prompt. Then you have to create an ssh key on each node and distribute the public key to everyone else.

```bash
# node-1 (192.168.178.21)
ssh-keygen -t ed25519
# three times enter to accept file and empty passphrase
ssh-copy-id 192.168.178.21
ssh-copy-id 192.168.178.22
ssh-copy-id 192.168.178.23
```

```bash
# node-2 (192.168.178.22)
ssh-keygen -t ed25519
# three times enter to accept file and empty passphrase
ssh-copy-id 192.168.178.21
ssh-copy-id 192.168.178.22
ssh-copy-id 192.168.178.23
```

```bash
# node-3 (192.168.178.23)
ssh-keygen -t ed25519
# three times enter to accept file and empty passphrase
ssh-copy-id 192.168.178.21
ssh-copy-id 192.168.178.22
ssh-copy-id 192.168.178.23
```