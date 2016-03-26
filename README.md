# jashect
**Just Another Simplified Hurricane Electric Certification Tool** to pass the *daily tests* for your *HE.net IPv6 Certification*

## What?
Some people aren't happy enough with being a sage and are always dreaming about reaching the 1.5k points… but are just too lazy to submit a report every day.

What am I talking about? The glorious [IPv6 Certification](https://ipv6.he.net/certification/) where you have to fill daily tests 100 times to count yourself as one of the best. And exactly there is this tiny script for.

Inspired by [HECT](https://github.com/tactmaster/HECT).


## Dependencies and Test
For using it you should have installed binaries of…

* `bash` (*4.3.042-4*)
* `coreutils` (*8.25-1*)
* `curl` (*7.47.1-2*)
* `grep` (*2.24-1*)
* `sed` (*4.2.2-3*)
* `traceroute` (*2.0.21-1*)
* `whois` (*5.2.11-1*)

where the version is the Arch Linux-packageversion.
Next to this software you also need `ping6` or a `ping`-version with the `-6`-flag and `dig`.
Arch Linux shipps this software packaged as…

* `iputils` (*20150815.1c59920-3*)
* `bind-tools` (*9.10.3.P4-1*)

First execute the script in your shell and check if it's working for you (*works for me*™).

```bash
chmod +x jashect.sh
./jashect.sh username password
```


## Install
### systemd
If you're running a GNU/Linux with systemd you could run it with the following units:

```bash
cp jashect.sh /usr/local/bin/jashect
chmod +x /usr/local/bin/jashect
cp -r systemd/* /usr/lib/systemd/system
```

Now modify the content of `/usr/lib/systemd/system/jashect.service.d/local.conf`

```bash
systemctl daemon-reload
systemctl start jashect.timer
systemctl enable jashect.timer
```

There you go! You don't have to worry for the next 100 days. Maybe you want to disable the script after reaching 1.5k points because there are no brakes on the IPv6-Train :^)

### everything else
You could write a daily cronjob but it may fail because sometimes the script takes 5secs and sometimes 10secs. So you won't wait exactly 24 hours and your submission was rejected.. So perhaps it's a good idea to write two cronjobs separated for 12h or something like that.

