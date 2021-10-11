devops_workstation
==================

Instructions for setting up a DevOps development workstation.

This is assuming Mac OSX, but most of it will work with a Linux workstation. 

We will be:
* Setting up SSH
* Installing prerequisite software like git, homebrew, and ansible
* Installing basic development applications
* Checking out some of the devops codebase (optional)
* Setting up minikube (optional)
#### SSH Setup

 * Open up the `Terminal` app `Applications -> Utilities -> Terminal`

 * Set Up your ssh keys and add them to gitlab
```
ssh-keygen -t rsa -b 2048
```
Output similar to:
```
[myusername@mycomputer ~]$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/myusername/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/myusername/.ssh/id_rsa.
Your public key has been saved in /Users/myusername/.ssh/id_rsa.pub.
The key fingerprint is:
fd:8f:ea:79:3c:e8:33:3c:7c:d2:51:0b:cd:34:43:52 myusername@localhost.localdomain
The key's randomart image is:
+--[ RSA 2048]----+
|            .oE  |
|             .+  |
|             + o |
|         .  . +  |
|        S .  o . |
|           .. .  |
|         o +..   |
|          O.*o   |
|         o=O...  |
+-----------------+
```

 * Copy the ssh-rsa output and paste it to: https://git.umms.med.umich.edu/profile/keys

```
[myusername@mycomputer ~]$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvMabFbsL7vhVp6t6Wuto7H6Q2oudbibjAZkSGnczkw8OFkTisKixf3PgG4ya3n7VALvoN55jjegncAsU0v4Yh4vO5HJEJFzQ3fpP2rMmPHg7YkD8nN1VmEcfLMu3vaxxuDgcqYGPvbXp5YuK6Z8h3lSuN5mMRFfZUzf/JGTN0QbTOyu2MZGHdRrRq0VDl+0ZkuLbhblJc6CHLQ8o7Sj8f4LssQdVcKX4+zFUyjSgJKcQVzvVWNXw0232+rVsGsS8/W9Z0mz3mRvPaCYHhR+WZK9ym8o+uDCOoKjhF2aLVrYKhGyh/57T2kY3fYYv8cER4rVjbZMf8Fn5HZNa6NXFbQ== myusername@mycomputer.localdomain
```

 * Add the ssh-passphrase to your mac keychain
```
ssh-add -K
```
with output similar to:
```
Enter passphrase for /Users/myusername/.ssh/id_rsa: 
Identity added: /Users/myusername/.ssh/id_rsa (/Users/myusername/.ssh/id_rsa)
```
#### Install Prerequisite Software
 * Gain administrative privileges by opening `Finder`, and clicking on `Applications/Privileges.app` and `Request Privileges`

 * Test that you have admin access on the Terminal you can type `sudo -i` and ensure that you get a root shell.  Then type `exit` to bring you back to your `myusername` shell
 ** If you had Terminal app already open, you may have to `su myusername` and type your password, or restart the Terminal app before running the next steps
 * Ensure that xcode CLI tools are installed.  From a command line try the following (if you encounter failure, see below):

```
$ xcode-select --install
```
If the above command fails with an error like `Software Update does not have xcode...`, you need to open `Managed Software Center` and install `XCode`, and then run the command above again (`xcode-select --install`)


 * Create some devops workspace. Something like the following will work (and that directory will be assumed in all the examples):

```
mkdir -p ~/git/devops
```

 * Clone this repo:

```
cd ~/git/devops; git clone git@git.umms.med.umich.edu:devops/devops_workstation.git
```

 * Add your user information to your global git config

```
$ git config --global --edit
# This is Git's per-user configuration file.
[user]
# Please adapt and uncomment the following lines:
        name = John Walsh
        email = mjohnw@med.umich.edu
```


 * Run this command to install homebrew into /usr/local, brew's python3, and ansible in your home directory using easy_install and pip:

```
touch ~/.bashrc && touch ~/.bash_profile && cd ~/git/devops/devops_workstation; ./setup_ansible.sh

```
 ** It will ask for your password and confirmation before installing Homebrew
 ** If you see something like the following, you may have to manually add a keg-only path to your profile:
```
A CA file has been bootstrapped using certificates from the system
keychain. To add additional certificates, place .pem files in
  /usr/local/etc/openssl@1.1/certs

and run
  /usr/local/opt/openssl@1.1/bin/c_rehash

openssl@1.1 is keg-only, which means it was not symlinked into /usr/local,
because openssl/libressl is provided by macOS so don't link an incompatible version.

If you need to have openssl@1.1 first in your PATH run:
  echo 'export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"' >> ~/.bash_profile

For compilers to find openssl@1.1 you may need to set:
  export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
```


* Source the Bashrc profile and confirm it has ansible installed and working:

```
$ . ~/.bash_profile
$ which ansible-playbook
```

#### Installing basic development applications

* Retrieve the `devops-workstation-vault-pass` vault password from the CyberArk Password Vault (located at idm.med.umich.edu).  You do need to be on the Michigan Medicine VPN.  If you are not on the VPN, and do not have a `UMHS SSL VPN` option in your `Cisco AnyConnect` client, manually type in `vpn.med.umich.edu`, click `connect` and authenticate with your **LEVEL 1 Login**

* Install prerequisite ansible roles:
```
cd ~/git/devops/devops_workstation && ansible-galaxy install --force --roles-path=./roles -r roles/requirements.yml
```

* Run this command to setup your workstation's development applications (entering the vault password you retrieved in a previous step when prompted). :
```
cd ~/git/devops/devops_workstation && ansible-playbook devops-workstation.yml --ask-vault-pass -e ansible_user=$(whoami)
```

#### Cloning some of the devops codebase

* Run this command to setup some basic git repositories that you might need (entering the vault password you retrieved in a previous step):
```
cd ~/git/devops/devops_workstation && ansible-playbook clone_git.yml --ask-vault-pass -e ansible_user=$(whoami)
```

#### Storing and Using an Ansible Vault password in Google Secret Manager
* Retrieve the `hits-sds-devops-vault-pass` vault password from the CyberArk Password Vault (located at idm.med.umich.edu).  You do need to be on the Michigan Medicine VPN.  If you are not on the VPN, and do not have a `UMHS SSL VPN` option in your `Cisco AnyConnect` client, manually type in `vpn.med.umich.edu`, click `connect` and authenticate with your **LEVEL 1 Login**
* Using the text editor of your choice create the file /tmp/av and paste the value of the vault password into it.
* Store the password as a secret in Google's Secret Manager.  You should have a personal project ID where your GCP sandbox environment lives. (e.g. hits-devops-bbalk-70cb)
  ```
  gcloud config set project <project_id>
  gcloud secrets create av --data-file="/tmp/av"
  ```
* Run the get_vault.yml playbook to pull the secret into your /tmp directory where it will reside until your machine is rebooted and /tmp is cleared out.
  ```
  ansible-playbook get-vault.yml -e project_id=<project_id>
  ```
* You can now re-run this playbook whenever you want to pull your vault secret into /tmp/av
* Note: a section is added to .zshrc by the devops-workstation.yml playbook that will export the vault password file as an environment variable if the file exists. You will need to source your .zshrc file once for this to occur. Alternatively you can run `export ANSIBLE_VAULT_PASSWORD_FILE=/tmp/av` manually.

# Optional/Troubleshooting

#### If you have trouble installing Virtualbox
 * Confirm whether or not you need to disable "System Integrity Protection" in order to install virtualbox (https://silvae86.github.io/sysadmin/mojave/beta/vagrant/virtualbox/osx/macos/2018/07/10/running-vagrant-and-virtualbox-in-mojave-public-beta/)
 ** 2020-03-23 - this was not needed with a Izzy build (versus CoreMac v2)
```
Disable System Integrity Protection (SIP)
Yes, yes, I also hate this, but has to be done until Apple refreshes the list of allowed Kernel Extensions to allow VBoxDrv.kext to load properly in Mojave.

1. Reboot your Mac and hold Command + R (⌘ + R) before it boots.
2. Keep holding it until you see the progress bar
3. Wait for it to finish
4. At the top menu, select Utilities -> Terminal
5. Enter csrutil disable
6. Press Enter
7. Type reboot
```

#### Cloning some of the devops codebase (alternate method)
###### still looking into sub groups ...

1. Create a personal access token, [see here](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)
2. Switch to the directory you'd like all the repositories to be cloned, i.e `~/git/devops/`
3. Run the following python command in the directory hold all the repositories:
  ```
  python3 clone.py devops $YOUR_TOKEN
  ```

#### minikube setup
We have a playbook to start minikube and login to nexus so to make local kubernetes development a little easier

You can run it with:
```
ansible-playbook -i localhost, minikube.yml -e ansible_python_interpreter='/usr/local/bin/python3' --ask-vault-pass
```
output:
```
$ ansible-playbook minikube.yml
nexus username: mjohnw
nexus password:

...

PLAY RECAP ******************************************************************************************************
localhost                  : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
minikube-host              : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### THE NUCLEAR OPTION | Removal of all items installed with Homebrew

A script has been provided that will uninstall all items that have been installed by homebrew.  The following will continually list installed brew casks and formulae and uninstall them until the list is empty. Expect errors when dependencies that prevent uninstallation are encountered.  These items will be uninstalled in future iterations of the loop.
NOTE: THIS WILL REMOVE PYTHON AND ANSIBLE SO YOU WILL NEED TO START AGAIN WITH THE `setup_ansible.sh` SCRIPT
```
./uninstall_brew_apps.sh
```

# Ubuntu Installation Notes
* Set up SSH keys and profile like above
* Install python and ansible
  * `apt-get install python3-pip && pip3 install ansible`
* VPN install
  * https://documentation.its.umich.edu/vpn/vpn-download-linux-vpn-profile
  * Change the UMVPN-2.xml to utilize UM Health url (vpn.med.umich.edu) by adding a new `<HostEntry>` tag
  * `~/anyconnect-linux/Profiles/vpn/UMVPN-2.xml`
  
  * 	<HostEntry>
        <HostName>UoM Health</HostName>
        <HostAddress>vpn.med.umich.edu</HostAddress>
      </HostEntry>

  * Run the `linux-devops-workstation.yml` playbook to install needed tools:
```
cd ~/git/devops/devops_workstation && ansible-playbook linux-devops-workstation.yml --ask-vault-pass -e ansible_user=$(whoami)
```
