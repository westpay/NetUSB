## What is NetUSB?
**Westpay NetUSB** is the name for our implementation of Remote NDIS (RNDIS) in our payment terminals.

RNDIS is a method of providing IP connectivity over USB. We use this feature in combination with Internet Connection Sharing (ICS) to supply the terminal with external network connection over USB. 

### What will i find in this repo?
This repo contains information, instructions and helpful scripts that can be used to automate or simplify the activation of ICS (Internet Connection Sharing) between the Host (PC) and our Device (Westpay payment terminal). _Please note that the instructions, tools here is offered without support and is only meant to be used as reference._

***

## Tools

### EnableTerminalConnectionSharing.ps1
|  |  |
| - | - |
| Source | [EnableTerminalConnectionSharing.ps1](https://github.com/westpay/NetUSB/blob/master/EnableTerminalConnectionSharing.ps1) |

**This script will:**
1. Find the network interface that have the description (Remote NDIS based Internet Sharing Device)
2. Find the interface that have a uplink and active state (In other words, internet connection)
3. Try to share the internet from (2) -> (1)

To use the script you simply call the script without any parameters
`./EnableTerminalConnectionSharing.ps1` from a elevated powershell command prompt or call the script via powershell.exe during system startup.

The script accepts two optional parameters
| Parameter | Description | Example | Mandatory |
| ----------- | ----------- | --- | --- |
| -internetInterface | Defines the interface that should have it's internet shared with the terminal | -internetInterface "WiFi" | No |
| -Disable | Disables the interent sharing between the defined network i/f and the terminal | -Disable:$True | No |

_(Note, the script will try to find everything automatically if no parameters is provided)_

***

## Guides & Information

_**Checkout our [Wiki](https://github.com/westpay/NetUSB/wiki) to find out more**_

