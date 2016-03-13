# jashect
**Just Another Simplified Hurricane Electric Certification Tool**

## What?
Some people aren't happy enough with being a sage and are always dreaming about reaching the 1.5k points… but are just too lazy to submit a report every day.

What am I talking about? The glorious [IPv6 Certification](https://ipv6.he.net/certification/) where you have to fill some stats for 100 days to count yourself as one of the best. And exactly this does this tiny script for you.

This software was inspired by [HECT](https://github.com/tactmaster/HECT).


## Test
Your system should have installed binaries of `traceroute`, `dig`, `whois` and `ping6` or a new `ping`-version with the `-6` flag.

At first you should execute the script once in your shell and check if it's working for you (*works for me*™).

```bash
chmod +x jashect.sh
./jashect.sh username password
```


## Install
### systemd
If you're running a GNU/Linux with systemd I wrote the services for you.

```bash
# cp jashect.sh /usr/local/bin/jashect
# chmod +x /usr/local/bin/jashect
# cp -r systemd/* /usr/lib/systemd/system
```

Now modify the content of `/usr/lib/systemd/system/jashect.service.d/local.conf`

```bash
systemctl daemon-reload
systemctl start jashect.timer
systemctl enable jashect.timer
```

There you go! You don't have to worry for the next 100 days. Maybe you want to disable the script after reaching 1.5k points because it has no brakes…

### everything else
You could write a daily cronjob but it may fail because sometimes the script takes 5secs and sometimes 10secs. So you won't wait exactly 24 hours and your submission was rejected..

Another *genial* idea is already written in the `yolo.sh` (*You Only Loop Once*) which exactly does what its name says: It loops n times and sleeps one day between every iteration :^)

