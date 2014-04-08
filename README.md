proxyswitcher
=============

An Alfred.app workflow for switching proxy states of Mac OS X.

With this workflow, you will need not dive deepl into system preferences panel for toggling proxy states.

The searching keyword is names of the sevices, such as, `Wi-Fi`, `Ethernet`, etc.

By Default, ProxySwitcher will show all proxy options for each services. 

If you have a file named `.proxyswitcher.rc` in your home dir, then ProxySwitcher will only show proxy options for those services with names in this file, each service name is in one single line.

 You could get all available service names via this command:  `networksetup -listallnetworkservices`
 
 
 Requirements:
 
 1. Alfred.app with PowerPack activated.
 
 Install steps:
 
 1. Download the ProxySwitcher.alfredworkflow file.
 
 2. Double-click it.
 
 3. If you want ProxySwitcher only show proxy options for Wi-Fi, then you can put one line `"Wi-Fi\n"`(without quotes, and `\n` means an UNIX new-line character) into `~/.proxyswitcher.rc`

 Screenshots:
 
 ![images](https://github.com/lululau/proxyswitcher/raw/master/screenshot.png)
