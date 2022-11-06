# Vagrant Development Environment: DevEnv

This Vagrant Setup provides you with a basic Ubuntu 18.04.2 LTS (Bionic Beaver) that contains everything that you needed to develop with PHP (multiple versions are availble and can be enabled in config: 5.6, 7.4, 8.0 or [switched to](#switching-between-php-versions) instantly). It contains the Apache2 Web Server, MySQL Server, Varnish, Redis as well as many common tools.

Installed dependencies can be found in [config.yml -> roles](config.yml).

## Table of contents

  * [Installation](#installation)
    * [Prerequisites](#prerequisites)
    * [Clone the repository](#clone-the-repository)
    * [Customize the machine config](#customize-the-machine-config)
        * [Available options and parameters for hosts](#available-options-and-parameters-for-hosts)
        * [Additional parameters](#additional-parameters)
    * [Add hosts to local system's hosts file](#add-hosts-to-local-systems-hosts-file)
    * [Install additional modules](#install-additional-modules)
  * [SSL/TLS](#ssltls)
    * [Install for Google Chrome on MAC](#install-for-google-chrome-on-mac)
    * [Install for Google Chrome on Windows](#install-for-google-chrome-on-windows)
    * [Install for Firefox](#install-for-firefox)
  * [Switching between PHP versions](#switching-between-php-versions)
  * [Debugging with PHPStorm: Xdebug](#debugging-with-phpstorm-xdebug)
    * [Xdebug on the CLI](#xdebug-on-the-cli)
  * [Redis](#redis)
  * [Varnish](#varnish)
  * [Ruby via rbenv](#ruby-via-rbenv)
  * [Vagrant share](#vagrant-share)
  * [RabbitMQ](#rabbitmq)
  * [Mercure](#mercure)
  * [Utilities](#utilities)
    * [Mailcatcher](#mailcatcher)
      * [Use in Laravel](#use-in-laravel)
      * [Use in Symfony](#use-in-symfony)
    * [enable_swap](#enable_swap)
    * [xdebug](#xdebug)
    * [bench](#bench)
    * [Blackfire](#blackfire)
    * [Upstart jobs](#upstart-jobs)
    * [SSH tunnel](#ssh-tunnel)
    * [vagrant-fsnotify](#vagrant-fsnotify)
    * [SFTP server](#sftp-server)
    * [ZSH shell](#zsh-shell)
  * [Known issues](#known-issues)
  * [Troubleshooting Vagrant/Ansible errors](#troubleshooting-vagrantansible-errors)

## Installation

### Prerequisites

- [vagrant >=2.2](https://www.vagrantup.com/downloads.html) 
- [virtualbox >=5.1](https://www.virtualbox.org/wiki/Downloads)
- nfs-kernel-server (linux: sudo apt-get install nfs-common nfs-kernel-server)
- [vagrant-winnfsd](https://github.com/winnfsd/vagrant-winnfsd) (windows)
- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)
- [vagrant-disksize](https://github.com/sprotheroe/vagrant-disksize)

### Clone the repository

Clone this repository to your machine:

```
git clone git@github.com:numediaweb/devenv.git
cd devenv
```

### Customize the machine config
 
Every parameter you find under config.yml can be overwritten in your personal config-custom.yml.

Customize the configuration file by making a copy of `config-custom.yml.dist`

```
cp config-custom.yml.dist config-custom.yml
```

1. Replace [YOUR_SHARED_FOLDER_WORKSPACE] with your local workspace e.g. synced_folder: "/Users/almu/projects"
2. Add the roles/modules you want to load.

```
synced_folder: "/Users/almu/projects"
roles:
  - common
```
3. Add the projects you work on (normally the ones you have in YOUR_SHARED_FOLDER_WORKSPACE )

```
vhosts:
  - { projectFolder: "my-project-folder", host: "my-project.dev", framework: "symfony", alias: "myalias" }
```

Start the machine with `vagrant up --provision`

#### Available options and parameters for hosts

The `vhosts` parameter accepts the following:
* `projectFolder`: the folder name in your local machine
* `directory`: the directory path that will be used as a DocumentRoot in Apache conf file (example: `/var/www/my-project-folder`). This is required for projects using `none` or `rails` framework: for the other frameworks the `projectFolder` will be used instead if no `directory` is specified.
* `host`: the host name that you want to give for this project in the format `my-project.dev`
* `framework`: this defines how the virtual host will be setup in Apache. Currently we support those options: `symfony` for Symfony 3 projects, `laravel` for Laravel projects, `none` for other non custom projects, `rails` for Rails applications. 
* `frameworkVersion`: this is used now for Symfony projects as Symfony 3 web folder is different than newer Symfony 4/5. Default is newer `public` folder.
* `alias`: optional alias to easily cd to the project folder in the virtual machine using cd-myalias form.
* `ssl`: by defaut all hosts have SSL, set it to `false` to disable SSL on the virtual host.

#### Additional parameters

* `port`: used to setup ProxyPass for Rails applications.
 
### Add hosts to local system's hosts file

The IP corresponds to the `vm_ip` inside the config.

 ```
 sudo nano /private/etc/hosts
 or
 sudo nano /etc/hosts

192.168.56.12 my-project.dev
```
 
Notes about the `ERR_ICANN_NAME_COLLISION` bug on Windows; if you see this error on your Chrome browser, try to edit the hosts file and put the problematic address on a new line!

## SSL/TLS

1. In your custom config file change the default password:
```yaml
ssl:
    pass_phrase: "create a strong password"
```

2. Go the the expected folder: `cd ansible/roles/apache/files/`.

3. Generate a private key for the CA:
```shell
openssl genrsa -aes256 -out ca_key.key 4096
```

4. Generate the X509 certificate for the CA:
```shell
openssl req -config openssl-ca.cnf \
   -new -x509 -nodes \
   -key ca_key.key \
   -out root_certificate_authority.pem
```

This dev environement expects the generated certificate to be copied to  [ansible/roles/apache/files/root_certificate_authority.pem](ansible/roles/apache/files/root_certificate_authority.pem) in order to trust the hosts from dev environement.

Due to Google Chrome [requiring ssl](https://goo.gl/5ZqJ8a) when using the .dev TLD: every host now has ssl by default.
If you want to disable ssl for any given host set it to `ssl: false` in the vhosts config:
```
  - { projectFolder: "my-project-folder", host: "my-project.dev", framework: "symfony", alias: "myalias", ssl: false }
```

Run `vagrant provision` to generate the certificates.


You can always check a dev domain's certificate using for example: `sudo openssl x509 -in /etc/apache2/ssl/my-project.dev.crt -text -noout`

### Install for Google Chrome on MAC

* Add the previously generated [ansible/roles/apache/files/root_certificate_authority.pem](ansible/roles/apache/files/root_certificate_authority.pem) certificate to the `login` keychain not the System keychain. But if you want to trust the certificates for others users of the mac you should add it to System keychain.
* In the Keychain Access search for the certificate you have just added and double click on it to open and choose “Always Trust,” and type your OSX user password.

Tip:
```
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" root_certificate_authority.pem
```

### Install for Google Chrome on Windows

* Use Chrome's Settings -> show advanced settings -> Manage Certificates -> Import.
* Add the the previously generated [ansible/roles/apache/files/root_certificate_authority.pem](ansible/roles/apache/files/root_certificate_authority.pem) certificate to `Trusted Root Certification Authorities`.


### Install for Firefox

* Go to firefox [preferences](about:preferences) and search for `view certificates` to open the certificate manager.
* Go to `Authorities` and click on `import` and add the the previously generated [ansible/roles/apache/files/root_certificate_authority.pem](ansible/roles/apache/files/root_certificate_authority.pem) certificate to be truested.


## Debugging with PHPStorm: Xdebug
You can use Xdebug (currently supporting version 3) both on the browser or the CLI. Follow the basic setup as explained on the [PHPStorm website](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html).

Remember to configure the server setting in PHPStorm to `Use path mappings` and set your project file to point to project folder `/var/www/example-project` (or whatever your project you are working on) in the Absolute path on the server.

If your app talks to other apps (you have locally) add them as local libraries in order to debug them from your current app: Remember to increase the number max simultaneous connections in PHPStorm.

For multiple connections: Increasing the number of simultaneous debugger connections as [explained here](https://www.jetbrains.com/help/phpstorm/simultaneous-debugging-sessions.html#9081626f)

### Xdebug on the CLI

Let's say you want to debug the project named `example` that uses `example.dev` as a host name. 
- SSH to your VM and run `export PHP_IDE_CONFIG="serverName=example.dev"`.
- Go to PHPStorm and click on the small icon on the debug bar named *Start Listening for PHP Debug Connections* 
- Run your script (ex. `php bin/console tagging:import-feedback`)

### Xdebug and RabbitMQ consumer commands

Running `c rabbitmq:consumer -m 100 work_queue_consume` doesn't triger xdebug in the IDE. To make PhpStorm aware of the connection you need to prefix the command with the environement variable: `PHP_IDE_CONFIG="serverName=snfreports-mic.dev" php bin/console messenger:consume rabbit`

## Switching between PHP versions

This DevEnv contains a utility script that allows switching between different available PHP versions. To switch to PHP 8.0 do:
```shell
phpswitch 8.0
```

## Redis

The latest stable version will be installed and the host will be `127.0.0.1` and port `6379`.

Check if Redis is correctly installed with 
```shell
redis-cli -a redis
127.0.0.1:6379> set foo bar
OK
127.0.0.1:6379> get foo
"bar"
````

## Varnish

Edit configuration for Varnish by making a copy of `config.yml => varnish` entry into `config-custom.yml`.

With default parameters you can access the Varnish Cache CLI using `varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret`

## Ruby via rbenv

see: the configuration for [ansible-rbenv-role](https://github.com/zzet/ansible-rbenv-role).

## Vagrant share

Vagrant Share allows you to share your Vagrant environment with anyone in the world, enabling collaboration directly in your Vagrant environment in almost any network environment with just a single command: `vagrant share`.

First, you need to create a free account at [HashiCorp's Atlas](https://vagrantcloud.com/account/new). Now when you run `vagrant share` it will create a Vagrant Share session with URL: you need to add this URL (Ex. http://bulky-mink-2323.vagrantshare.com) as an alias to your virtual host. Example:

```
sudo nano /etc/apache2/sites-enabled/spaghetti.dev.conf
```

Then add `ServerAlias`:


```
    ServerName spaghetti.dev
    ServerAlias bulky-mink-2323.vagrantshare.com
```

## RabbitMQ
RabbitMQ is a message broker system which allows you to write messages to an exchange with one process, called the producer, and then read back from the queue with another process, called the consumer.

Access the RabbitMQ admin panel [http://192.168.33.12:15672/](http://192.168.33.12:15672/) (The IP corresponds to the `vm_ip` inside the config) using username `test` with password `test`.

The log files will be saved in `/var/log/rabbitmq/rabbit@example-devenv.log`.

An environment variables file define ports, file locations, names. To add configuration file for rabbitMq, edit this file (or create it if not existing): `/etc/rabbitmq/rabbitmq.config`
A configuration file defines component settings for permissions, limits and clusters, and also for plugins. To add environement variables for rabbitMq, edit this file (or create it if not existing): `/etc/rabbitmq/rabbitmq-env.conf`

Restart it with: `service rabbitmq-server restart`
Check status with: `rabbitmqctl status`

### Mercure

Test if Mercure is running `curl 127.0.0.1:3000` You should get a response like:
```html
<!DOCTYPE html>
<title>Mercure Hub</title>
<h1>Welcome to <a href="https://mercure.rocks">Mercure</a>!</h1>
```
If not then check if Mercure is running: `systemctl status mercure.rocks.service`

Start it with: `sudo systemctl start mercure.rocks`

See logs: `sudo tail -f -n 10 /var/log/mercure.log`

## Utilities

### Mailcatcher

Use instead mailtrap.io!

Mailcatcher doesn't work correctly on Ubunto 20.04

The dev environement contains [Mailcatcher](https://mailcatcher.me/) that runs a simple SMTP server which catches any message sent to it to display in a web interface. 

Create a tunnel:
```shell
ssh -fNg -L 1180:localhost:1080 vagrant@192.168.56.12 -p 22 -i /Users/aidrissi/devenv/.vagrant/machines/default/virtualbox/private_key
```

Access the Mailcatcher web insterface using [http://127.0.0.1:1180/](http://127.0.0.1:1180/)

If not started, ou can start mailcatcher with: `mailcatcher --smtp-ip 192.168.33.12 --smtp-port 1025`

#### Use in Laravel
Edit mail.php with: 
```
return ['driver' => 'smtp', 'host' => '192.168.33.12', 'port' => 1025, 'from' => array('address' => 'test@mailbox.dev', 'name' => 'Test Email Sender'), 'encryption' => false, 'username' => null, 'password' => null];
```

#### Use in Symfony
Use those parameters:
```
    mailer_transport: smtp
    mailer_host: 192.168.33.12:1025
    mailer_user: null
    mailer_password: null

```
If you still have issues seeing the emails, then comment the `    spool:     { type: memory }` in config.yml. When you use spooling to store the emails to memory, they will get sent right before the kernel terminates. This means the email only gets sent if the whole request got executed without any unhandled exception or any errors. 

### enable_swap
command to enable swap memory when having [trouble with composer](https://getcomposer.org/doc/articles/troubleshooting.md#proc-open-fork-failed-errors)

### xdebug
By default Xdebug is turned off, to enable it run on the VM `xdebug on`. If you want to swith xdebug off then simply run `xdebug off`.

### bench
Runs a PHP benchmarking script and displays script execution time. Try it eith xdebug set to off: the average total time is 3 seconds or less.

### cd shortcut
For every project you have a cd shortcut/alias to jump directly to the projects root folder.
By typing `cd-` you will get autocompletion to all defined projects and you will redirected to the right folder while executing the command

### Blackfire

Blackfire.io makes it possible to write performance tests, automate test scenarios, and drill down to the finest details whenever performance issues arise. We have the Blackfire included in the devenv but you need to configure it:
* Download the Blackfire extension for [Google Chrome](https://blackfire.io/docs/integrations/chrome#installing-the-companion).
* Create a free account on [Blackfire.io](https://blackfire.io)
* Configure your Blackfire credentials [which you can get once you register](https://blackfire.io/docs/up-and-running/installation)
* Edit config-custom.yml by adding the credentials you got. Example:
```
blackfire:
    server_id: 438c6b48-399f-493d-8885-2a38dc11de73
    server_token: 7518bc8c2f0fdd6c6ba1735e2606a5c4694f9db8b776de868a659a89f21ec233
```
* Run the vagrant provision for the changes to take effect `vagrant provision`

### Upstart jobs
We had setup few upstart jobs specially for all gulp projects. By convention directory name setup in `config.yml` are the upstart job names. So you can start/stop these jobs into VM. e.g. 

```
vagrant ssh
sudo service voe-frontend stop
sudo service voe-frontend start
```

### SSH tunnel
Enable the `ssh_tunnel` role in the config to allow the VM to connect to an ssh tunnel. This is needed for the supdb access. 
You need to add your private ssh key inside the `private` folder and add/edit this config into your `config-custom.yml`:
```
ssh_tunnel:
    keys_map:
      - src: '../../../private/id_rsa'
        dest: ~/.ssh/id_rsa
        owner: vagrant
        group: vagrant
    host: 'sup-db.example.de'
    forward: '3308:sup-db:3306'
    port: 32642
    user: tunnel
```

You can check for the tunnel if it is working by `sudo netstat -tulpn | grep "3308"`

You connect to the db with `mysql -umyusername -pmypassword -h 127.0.0.1 -P 3308 example`

To kill/stop the tunnel do this: 
```
# list all services using ssh tunnel local port
$ ps aux | grep ssh | grep 3308
root     14634  0.0  0.0  53540  1692 ?        Ss   08:31   0:00 ssh -f tunnel@sup-db.example.de -p 32642 -L 3308:sup-db:3306 -N -i /root/.ssh/xx
root     20093  0.0  0.0  53004   924 ?        Ss   08:41   0:00 ssh -f tunnel@sup-db.example.de -p 32642 -L 3308:sup-db:3306 -N -i /root/.ssh/xx
root     26778  0.0  0.0  53004   928 ?        Ss   09:34   0:00 ssh -f tunnel@sup-db.example.de -p 32642 -L 3308:sup-db:3306 -N -i /root/.ssh/xx

# kill all those processes
$ sudo kill 14634 20093 26778

```

### vagrant-fsnotify

Forward filesystem change notifications to your Vagrant VM. 

To install it run: `vagrant plugin install vagrant-fsnotify` then add this to your `config-custom.yml`:
```
synced_folder_append_params:
    :fsnotify: true
```
Then start the machine and use `vagrant fsnotify`: This starts the long running process that captures filesystem events on the host and forwards them to the guest virtual machine.

### SFTP server

Use this settings to login to the devenv sftp server:
* user: `sftp_foo`
* host: `192.168.33.12` (VM IP address)
* port: `22`
* key file for user is [ansible/roles/sftp/files/sftp_foo](ansible/roles/sftp/files/sftp_foo)

### ZSH shell

ZSH is a terminal that can pratically predict what you want to type, save a lot of repetitive commands, give you a really powerful autocomplete. Based on [ansible-role-zsh](https://github.com/viasite-ansible/ansible-role-zsh)

## Troubleshooting Vagrant/Ansible errors

### ERROR: Module mpm_event is enabled - cannot proceed due to conflicts

If you experience this error:

`failed: [default] (item=php7.4) => {"changed": true, "cmd": ["a2enmod", "php7.4"], "delta": "0:00:00.031828", "end": "2019-01-17 09:27:19.636172", "item": "php7.4", "msg": "non-zero return code", "rc": 1, "start": "2019-01-17 09:27:19.604344", "stderr": "ERROR: Module mpm_event is enabled - cannot proceed due to conflicts. It needs to be disabled first!\nERROR: Could not enable dependency mpm_prefork for php7.4, aborting", "stderr_lines": ["ERROR: Module mpm_event is enabled - cannot proceed due to conflicts. It needs to be disabled first!", "ERROR: Could not enable dependency mpm_prefork for php7.4, aborting"], "stdout": "Considering dependency mpm_prefork for php7.4:\nConsidering conflict mpm_event for mpm_prefork:\nConsidering conflict mpm_worker for mpm_prefork:", "stdout_lines": ["Considering dependency mpm_prefork for php7.4:", "Considering conflict mpm_event for mpm_prefork:", "Considering conflict mpm_worker for mpm_prefork:"]}`

then first you need to ssh to the vagrant guest machine:
```
vagrant ssh
```
and run the following command:
```
sudo a2dismod mpm_event
```
then exit from the guest machine and run `vagrant up --provision`


### The apps are slow

First run the `bench` command to see if this has to do with the dev environement.

If you are using Symfony then set this on the config:
```
framework:
   session:
       save_path:   null
```
       
### NFS is reporting that your exports file is invalid
Seems a few invalid entries exist in /etc/exports. Clean up that file and restart the vagrant box.

```
sudo rm /etc/exports
sudo touch /etc/exports

vagrant halt
vagrant up --provision
```

### Memory issues

### No disk space left

* Remove not needed websites from the root directory. 
* Delete Apache logs: `sudo find /var/log/apache2/ -name '*.log' -delete`
* You can also remove uneeded files only and keep the websites.
* Delete not needed databases. Use `select @@datadir;` MySQL query to find where the data is stored: normally inside `/var/lib/mysql/` directory.
* `sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge`
* `sudo rm /var/log/*.gz`
* `sudo du --max-depth=1 --human-readable /var | sort --human-numeric-sort`

#### Large Databases

use this query to list the size of every table in every database, largest first:
```mysql
SELECT 
     table_schema as `Database`, 
     table_name AS `Table`, 
     round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM information_schema.TABLES 
ORDER BY (data_length + index_length) DESC;
```


### composer

composer is running sometimes into a memory limit: https://getcomposer.org/doc/articles/troubleshooting.md#memory-limit-errors

Run `enable_swap` command

### 'apache2/envvars does not exist' on ubuntu host

First delete the following

1. the vm machine folder (ex: devenv_default_1479138737761_89236)
2. .vagrant folder inside the devenv
3. this is optional but also helps clear the vagrant box: search for this folder “vagrant.d” you will find a sub folder named “boxes”… just clear its content

Open Vagrantfile and change line number 34 from config.vm.synced_folder parameters['synced_folder'], "/var/www", create: true, type: "nfs" to config.vm.synced_folder parameters['synced_folder'], "/var/www", create: true, type: "rsync"

After machine is provisioned successfully, change this back to 'nfs'

### Error: EACCESS, unlink /var/www/project_name/node_modules/.bin/*
Simply remove the `node_modules` folder from host machine and re-run the service. sudo service pulse-frontend restart

### Syntax error: “fi” unexpected (expecting “then”) in bash script

Most probably this is because carriage-return `\r`. To fix this use the dos2unix command. Ex. `dos2unix ansible/roles/common/files/bin/changephp_7.4.sh `

### Vagrant was unable to mount VirtualBox shared folder

Vagrant doesn't start and you get this error:

```
For context, the command attempted was:

mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant

The error output from the command was:

/sbin/mount.vboxsf: mounting failed with the error: No such device
```

This is related to the version of your guest addition and virtual box (`vboxmanage --version`): probably they are broken or missmatch. You need to install the right guest additions for your system:

* Install the vagrant-vbguest plugin: `vagrant plugin install vagrant-vbguest`. 
* Reload vagrant `vagrant reload && vagrant halt && vagrant up --provision`.

### Segmentation fault (core dumped)

Apache couldn't start as some configuration went wrong. The problem may occur because we previously installed php5.6 and php7.4 Run:
```
sudo a2dismod php5.6 php7.4 php8.0 && sudo service apache2 restart && sudo systemctl status apache2
```

Tips: 
* Use `sudo apache2ctl -V` to get server config like: version, configuration file path etc..
* Check status `sudo systemctl status apache2` or `sudo systemctl status apache2.service`
* View error logs: `sudo find /var/log/apache2  -name "*.log" | sudo xargs tail -f -n 100`
* View error logs: `sudo apache2ctl status`
* Show enabled modules: `sudo apache2ctl -t -D DUMP_MODULES`

### Database Connection error of authenticate key on SSH tunnel:
Remove the key from file /home/coeus/.ssh/known_hosts against the IP 192.168.33.12. And then re-test the connection. It will add the new key and will proceed successfully.

### Errors on Apache
Most errors on Apache are related to wrong or non existing hosts files or non existing project folders `projectFolder`. 

1. First of all follow the steps in [customize the machine config](#customize-the-machine-config) so that you include only the projects you have on your machine. 
2. Clear the existing vhosts in the VM: 
```
vagrant ssh
sudo rm -rf /etc/apache2/sites-available/*.*
sudo rm -rf /etc/apache2/sites-enabled/*.*
sudo rm -rf /etc/apache2/ssl/*.*
exit
```
3. Now run again `vagrant provision`

### ERROR! no action detected in task

If you face some error like:

```
vagrant up --provision
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Running provisioner: ansible_local...
    default: Running ansible-playbook...
ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path.

The error appears to have been in '/vagrant/ansible/roles/apache/tasks/main.yml': line 3, column 3, but may
be elsewhere in the file depending on the exact syntax problem.
```
Upgrading your versions of VirtualBox and Vagrant to latest versions may fix the issue.

### Failed to update apt cache.
iled

W: Failed to fetch http://repo.varnish-cache.org/ubuntu/dists/lucid/varnish-3.0/binary-amd64/Packages  410  Gone [IP: 176.58.90.154 80]

E: Some index files failed to download. They have been ignored, or old ones used instead.
vagrant@example-devenv:~$ exit

sudo apt-get clean 
sudo apt-get update

### file_put_contents(): Exclusive locks are not supported for this stream

Fix : Replace line in Vagrantfile

    config.vm.synced_folder parameters['synced_folder'], "/var/www",  parameters['synced_folder_append_params'].merge({create: true, type: "nfs"})

with 

    config.vm.synced_folder parameters['synced_folder'], "/var/www",  parameters['synced_folder_append_params'].merge({create: true, type: "nfs",mount_options: ["rw", "tcp", "nolock", "noacl", "async"]})

    
### SSL certificate issue
A recent bug appeared on v3 and related to the self signed certificates being not accepted (`/etc/apache2/ssl/root_certificate_authority.pem`). To temporary fix this for composer:
```bash
sudo wget -O /usr/lib/ssl/cert.pem "http://curl.haxx.se/ca/cacert.pem"
composer config --global cafile '/usr/lib/ssl/cert.pem'
```

### Fix `Signature expired` errors

Sometimes, the time in the Development VM can go out of sync with the time in the host machine.
To verify if the time is out of sync, run the `date` command both in your host machine and in the vm. If the results are different, run the following command in the vm to fix the issue: 
```
$ sudo /usr/sbin/VBoxService --timesync-set-start && sudo ntpdate pool.ntp.org
```

### Setup AWS

If you are using the AWS SDK for PHP (starting from version 2.6.2), you can use an AWS credentials file to specify your credentials. This is a special, INI-formatted file stored under your HOME directory, and is a good way to manage credentials for your development environment. The file should be placed at `~/.aws/credentials`, where ~ represents your HOME directory.

Here's an example:
```
[default]
aws_access_key_id = SOME_KEY_HERE
aws_secret_access_key = SOME_SECRET_HERE

[prod]
aws_access_key_id = SOME_KEY_HERE
aws_secret_access_key = SOME_SECRET_HERE

[ari_stage]
role_arn = arn:aws:iam::12345678:role/app/ari
source_profile = default

[ari_prod]
role_arn = arn:aws:iam::12345678:role/app/ari
source_profile = prod
```

## TODO
* Add vagrant to adm group `sudo usermod -aG adm vagrant`
* Clean the apache logs `/var/log/apache2`
