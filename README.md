# SmartDNS

## Ansible

### install on master
```
apt-get update\
  && apt-get install -y --no-install-recommends git\
  && (git clone git@github.com:ab77/ansible-smartdns.git\
  || git clone https://github.com/ab77/ansible-smartdns.git)\
  && cd ansible-smartdns\
  && apt-get install -y --no-install-recommends\
  python-minimal python-pip python-setuptools\
  && pip install -r requirements.txt --upgrade\
  && ansible --version
```

### update master
To update the local repository from upstream master, run `git pull`.

### configure environment
All of the top-level environment variables are located in `environments/000_cross_vars` (e.g.):

```
# cross environment
ansible_ssh_user: root
resolvers:
  - 8.8.8.8
  - 8.8.4.4
dnsmasq_listen_addresses:
  - "{{ ansible_default_ipv4.address }}"
  - "{{ ansible_default_ipv6.address }}"
sniproxy_version: 0.5.0
sniproxy_mode: mode ipv4_only
bypass_sub_domains:
proxy_domains:
  - akadns.net
  - akam.net
  - akamai.com
  - akamai.net
  - akamaiedge.net
...
```

### deploy

#### dev

##### configure hosts
* create hosts file

```
cp environments/templates/hosts.template environments/dev/hosts
```

* populate `environments/dev/hosts` with IP addresses under relevant `[section]`

* create and add IPs to `environments/dev/files/ip_whitelist.txt` (e.g.):
```
149.101.145.11
121.212.175.192
10.145.74.106
182.34.28.163
170.116.31.140
```

* if not using IPv6, just `touch environments/dev/files/ip6_whitelist.txt`

* run playbook

```
ansible-playbook site.yml --inventory-file=environments/dev/hosts
```

#### live

##### configure hosts
* create hosts file

```
cp environments/templates/hosts.template environments/live/hosts
```

* populate `environments/live/hosts` with IP addresses

* create and add IPs to `environments/live/files/ip_whitelist.txt` and `ip6_whitelist.txt`

* if not using IPv6, `touch environments/live/files/ip6_whitelist.txt`

* run playbook

```
ansible-playbook site.yml --inventory-file=environments/live/hosts
```

### environment variables override (optional)
Environment variables are inherited from the top-level as follows:
* environments/000_cross_vars
* environments/dev/group_vars/all
* environments/dev/group_vars/{{group}}
* environments/dev/host_vars/{{host}}

Override environment variables at the host level as follows:

* create host skeleton under `host_vars`

```
cp -r environments/templates/{{env}}/host_vars/__template__\
  environments/templates/{{env}}/host_vars/{{ipaddr}}
```

* add override environment variables to `vars` (e.g.):

```
dnsmasq_listen_addresses:
  - 166.246.157.23
  - 99.34.68.44
  - 87.53.234.105
```

### secrets management (optional)
Sometimes it is necessary to store secrets (e.g. keys, passwords).

* create or edit Ansible vault in the appropriate directory (e.g. `environments/`)

```
ansible-vault edit 000_cross_vault || ansible-vault create 000_cross_vault

```
* create vault variables as follows

```
vault_my_secret: mysupersecretpassword
```

* reference secret in `vars` file as follows:

```
my_secret: "{{ vault_my_secret }}"
```

* reference `my_secret` environment variable in tasks as `"{{ my_secret }}"`

* store the vault secret password in `~/.ansible/credentials`

* run playbook unattended as follows:

```
ansible-playbook site.yml\
  --inventory-file=environments/live/hosts\
  --vault-password-file ~/.ansible/credentials
```
