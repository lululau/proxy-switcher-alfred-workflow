proxyswitcher
=============

## New design for current version 2.0.0:


An Alfred.app workflow for switching proxy states of Mac OS X.

With this workflow, you will need not dive deepl into system preferences panel for toggling proxy states.

This workflow will show proxy options(need to pre-configured in a dot file) of current primary network service (usually the "Wi-Fi" serivce on a MacBook X).

### Requirements:
 
 1. Alfred.app with PowerPack activated.
 
### Install steps:
 
 1. Download the ProxySwitcher.alfredworkflow file.
 
 2. Double-click it.

### Usage:

Put a file names `.proxyswitcher.rc` to your home directory, edit this file like this:

```yaml
AutoDiscoveryProxy:   # AutoDiscoveryProxy has no options
AutoProxy:
  URL: "file://localhost/Applications/Safari.app/Contents/Resources/autoproxy.pac"  # URL of pac file
SocksProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: true
  Username: hello
  Password: 123123
HTTPProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: false
HTTPSProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: false
FTPProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: false
RTSPProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: false
GopherProxy:
  Host: 127.0.0.1
  Port: 8080
  Auth: false
```

The workflow will only show proxies already pre-configured in `.proxyswitcher.rc` file.

In Alfre.app text input field, type "proxy", move cursor to one proxy option and press enter, the worlflow will toggle state of that proxy option.

## Specification for version 1.0.0:


An Alfred.app workflow for switching proxy states of Mac OS X.

With this workflow, you will need not dive deepl into system preferences panel for toggling proxy states.

The searching keyword is names of the sevices, such as, `Wi-Fi`, `Ethernet`, etc.

By Default, ProxySwitcher will show all proxy options for each services. 

If you have a file named `.proxyswitcher.rc` in your home dir, then ProxySwitcher will only show proxy options for those services with names in this file, each service name is in one single line.

 You could get all available service names via this command:  `networksetup -listallnetworkservices`
 
 
### Requirements:
 
 1. Alfred.app with PowerPack activated.
 
### Install steps:
 
 1. Download the ProxySwitcher.alfredworkflow file.
 
 2. Double-click it.
 
 3. If you want ProxySwitcher only show proxy options for Wi-Fi, then you can put one line `"Wi-Fi\n"`(without quotes, and `\n` means an UNIX new-line character) into `~/.proxyswitcher.rc`

### Screenshots:
 
 ![images](https://github.com/lululau/proxyswitcher/raw/master/screenshot.png)
