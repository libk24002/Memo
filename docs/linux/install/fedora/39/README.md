## install Fedira 39

### Requirements
* a machine with x86_64 cpu

### Installation
1. Choose installation language: "English" -> "English(United States)"
    + ![choose installation language](resources/choose.installation.language.png ':size=25%')
    + ![installation summary origin](resources/installation.summary.origin.png ':size=25%')
2. Keep Keyboard as "English(US)"
3. Configure network and hostname
    + turn network on
    + set hostname to "node-01"
    + ![configure network and hostname](resources/configure.network.and.hostname.png ':size=25%')
4. Set time&date:
    + turn network time on
    + open configuration page and add "ntp.aliyun.com" as ntp servers if origin one cannot connect to
    + set "Region" to "Asia" and "City" to "Shanghai"
    + ![set date and time](resources/set.date.and.time.png ':size=25%')
5. Keep installation source not changed(will be updated after network connected)
6. Choose local disk as "Installation Destination"
    + ![choose installation destination](resources/choose.installation.destination.png ':size=25%')
7. In "Software Selection"
    + choose "Fedora Server Edition"
    + do not add any additional software
    + ![software selection](resources/software.selection.png ':size=25%')
8. Set root password
    + ![set root password](resources/set.root.password.png ':size=25%')
9. Settings finished state: confirm and click "Begin Installation"
    + ![installation summary finished](resources/installation.summary.finished.png ':size=25%')
10. Waiting for installation to be finished
    + just click "Reboot System"
    + ![waiting for installation finished](resources/waiting.for.installation.finished.png ':size=25%')
11. Login and check
