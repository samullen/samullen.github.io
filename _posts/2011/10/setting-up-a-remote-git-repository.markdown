--- 
title: Setting Up a Remote Git Repository
date: 2011-10-01
comments: false
post: true
categories: [git, remote]
---
Recently, I was asked by a client to help them set up their remote [Git](http://git-scm.com/) repositories and define a workflow which would work best for their small development staff. I'm going to write something up about the workflow I've suggested for them, but for now, let's look at how to set up a remote repository.

For larger teams which require permissions to access projects, using a more involved system like [Gitosis](http://wiki.dreamhost.com/Gitosis), [Gitolite](https://github.com/sitaramc/gitolite), or [Github](http://github.com) might be a better solution, but for smaller teams, something simpler may be in order.

This post demonstrates how to easily set up a Git repository on a remote machine.

### Prerequisites
You'll need the following set up on the remote machine: 1) A user account which will have permissions to the repositories (I'm using "gituser" here); 2) public RSA keys to add to gituser's authorized_keys file; 3) Git will need to be installed on the remote machine (duh.)

If you are not familiar with how to do this, reference the "Further Reading" section below.

### Initializating the Remote
The first thing we'll do is set up the remote machine. On your remote machine, change to the directory into which you want to set up your repositories. I usually install mine under "/usr/local/gits". You can use the following command to do this:

``` bash
sudo mkdir -p /usr/local/gits/new_repository
```

The "-p" option will create all necessary directories if they don't already exist.

You'll need to change the ownership of repositories directory to the gituser account:

``` bash
sudo chown -R gituser:gituser /usr/local/gits
```

The "-R" option will change permissions (recursively) on the "gits" directory as well as all other directories within it. Remember that all future repositories will also need to be owned by gituser as well.

The last thing we'll do is initialize "new_repository" as a "bare" repository:

``` bash
git init --bare /usr/local/gits/new_repository
```

A "bare" git repository is "...a repository cloned using the `--bare` option, only includes the files/folders inside of the `.git` directory."

### Adding the Remote
Your remote repository should be set up now. It's time to add it to let your local repository in on the news. From within your project, use the following command:

``` bash
git remote add origin ssh://gituser@123.123.123.123/usr/local/gits/new_repository
```

"123.123.123.123" will be the IP address of the remote server.

At this point you should now be able to push to, pull from, and clone the new remote repository. If you experience an error here, it is likely because of a permissions problem or you have not added your id_rsa.pub key to gituser's authorized_keys file.

### Further Reading
* [The Git SCM](http://git-scm.com)
* [A Successful Git Branching Model](http://nvie.com/posts/a-successful-git-branching-model/)
* [Push to Only Bare Repositories](http://gitready.com/advanced/2009/02/01/push-to-only-bare-repositories.html)
* [adduser: Adding a New User](http://www.linuxheadquarters.com/howto/basic/adduser.shtml)
* [Generating RSA Keys](https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys)
* [SSH - Authorized keys HOWTO](http://www.eng.cam.ac.uk/help/jpmg/ssh/authorized_keys_howto.html)
* [Dropbox: An Unexpected Git Hosting Solution](http://samullen.posterous.com/dropbox-an-unexpected-git-hosting-solution)
