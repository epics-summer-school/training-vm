# Creating the EPICS Training VM

These instructions describe how to generate the VirtualBox VM
for the EPICS Training from scratch.
The recipe was set up using 6.1.50_Ubuntu r161033on Ubuntu 22.04,
but it should work similarly on other versions and host systems.

## Create the VM

Create a new virtual machine, using the Ubuntu 22.04 iso image.
(Both a local install from the 10GB DVD iso
or a network install from the 900MB boot iso work.)
Here are the settings we used.
More CPUs and memory always helps -
going lower than these values is not recommended.

![VBox Settings](/doc/training-vm-parameters.png?raw=true "VBox Settings")

You can use the "Server with GUI" or "Workstation" profiles,
no additional software modules are needed.

Create a user (we used epics-dev as the "EPICS Developer")
select "Make this user administrator" (which enables sudo).
We did not set a password, which is fine for a personal VM
that you run on your own computer/laptop.

Consider saving the state in a snapshot, *"22.04 fresh"*.

## Update the system

Become root.
```
$ sudo -i
```


## Allow passwordless sudo

Become root.

Edit `/etc/sudoers` (by commenting / uncommenting lines)
to allow the `wheel` group to run commands with `NOPASSWORD: ALL`.
This is needed for ansible to run.


## Get and run the bootstrap script

The remaining steps are done as the regular user.

Copy the script `bootstrap_redhat.sh` onto the VM and run it.
(Preferably from your home directory.)

This will make sure the required software is installed (git, ansible)
and clone this repository with the ansible configuration
into a directory called `bootstrap`.

## Create your local configuration

Inside the `bootstrap/ansible/group_vars` directory.

Edit `bootstrap/ansible/group_vars/local.yml`
to configure your training VM.

## Run ansible to install the system

```
$ bootstrap/update.sh 
```
will install or update the training VM according to your configuration.

The compiling jobs will take their time.
Subsequent runs of the script will not recompile modules unless necessary.

You will most likely need become pass to run the update, unless the Ubuntu is already configured not to use password.

```
./update.sh . 
```