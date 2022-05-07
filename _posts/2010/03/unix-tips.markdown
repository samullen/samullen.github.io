---
title: Unix Tips
date: 2010-03-18
post: true
categories: [tips, unix, cli]
---

Peteris Krumins posted a nice little article today titled "[Top Ten One-Liners from CommandLineFu Explained](http://www.catonmat.net/blog/top-ten-one-liners-from-commandlinefu-explained/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed:+catonmat+(good+coders+code,+great+reuse))". Two of these "one-liners" stood out to me:

\#6 Quickly backup or copy a file - "cp filename{,.bak}" - This is a one-liner to copy the file and add a ".bak" extension to it. But remembering that command is a little hard, so instead, I added the following to my .bashrc file:

``` bash
function backup {
  cp ${1}{,.bak}
}
```

Now I can just type `backup filename`

\#9 Copy your public-key to remote-machines for remote authentication - `ssh-copy-id remote-machine` - I never knew about this command before, but I guarantee I'll never forget it.

> This one-liner copies your public-key, that you generated with ssh-keygen (either SSHv1 file identity.pub or SSHv2 file id_rsa.pub) to the remote-machine and places it in ~/.ssh/authorized_keys file. This ensures that the next time you try to log into that machine, public-key authentication (commonly referred to as "passwordless authentication.") will be used instead of the regular password authentication.

** Update - A bit later than the original posting:**

Our servers here have some really long names. Something like 'ProcessServer12.fac.company.com". To ssh into those servers I could either memorize the IP addresses - which I have - or I can type in the server name. If I had "fac.company.com" in my /etc/resolv.conf, I could just ssh to ProcessServer12, but since my resolv.conf file get overwritten each reboot, I had to find a workaround.

In my .bashrc I added the domains and subdomains of the servers to my LOCALDOMAIN variable:

``` bash
export LOCALDOMAIN="fac.company.com company.com foo.bar.baz.anothercompany.com"
```

This is better because it's a local change rather than a global change
