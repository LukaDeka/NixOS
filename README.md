# Introduction
This is the documentation to present the services I have running on my home server.
While this project started off as experimentation, I now use these services daily.

My aim is to keep this configuration easily deployable, while not locking in the user
with predefined options. Thus I declared variables in `packages/variables.nix` that
can be set in `configuration.nix`, so that there aren't many hard-coded values.

> [!CAUTION]
> Do not clone my configuration blindly without understanding how each
> component works. Make sure you handle your and others' data responsibly
> and add services/features one-by-one.

# Cloudflare

If your router is behind a CGNAT or you're unable to forward ports in your router/firewall,
using `Cloudflare Zero Trust` is a must. I don't have it set up since there's no need.

Cloudflare also allows you to use their proxy, if you don't want your IP address exposed to
the public (in your DNS records), and want to enable *Geoblocking, DDOS protection, WAF rules*
and many other useful features.

## DNS setup

After purchasing your domain, set the nameservers so Cloudflare's ones in your domain
registarar's website. After the records have propagated, proceed with the setup and
make the DNS records for the services you want available outside the home network.
You can set a placeholder IP address in the `Content` tab since the script located in
`scripts/cloudflare/ddns.sh` updates the records similarly to *DuckDNS*. Check the log
in the same directory to see if it succeeded.

> [!IMPORTANT]
> If you decide to use Cloudflare's proxies (set in the `DNS` section), **make sure to enable**
> `Full (strict)` **encryption under** `SSL/TLS` to ensure proper encryption.
> Refer to [this blog by Cloudflare](https://community.cloudflare.com/t/why-you-should-choose-full-strict-and-only-full-strict/286652) for details.


# DuckDNS

[DuckDNS](https://www.duckdns.org/) allows you to create a Dynamic DNS (DDNS) record that points to
your dynamic IP address. This is very useful when you don't have a static IP address
from your ISP and want a reliable way to have a hostname resolve to your IP.

I'm running a *systemd service* in `scripts/duckdns/service.nix` every 30 minutes that tries
to update the IP address, in case it has changed.


# Nextcloud

This is the main app I use for *photo synchronisation, calendar, file sharing, live spreadsheets*
*in the web (Collabora online), notes, polls, tasks* etc. It's a replacement for the following services:
*Google Photos/Calendar/Drive/Docs/Sheets/Notes/Tasks* etc.

I found these Android apps available from [F-Droid](https://f-droid.org/en/) to integrate best with Nextcloud:
*Nextcloud, Nextcloud Memories, OneCalendar, Nextcloud Deck, Quillpad (for notes).*

## Email

### Motives
Because I'm running my Nextcloud instance from my home network and I don't
have a static IP, I'm unable to get the DNS-zone from my ISP required to publish
my own reverse DNS (rDNS) record. Thus if I were to run my own mail server,
my mails would be marked as spam because of lack of said record.

For now I decided to let Gmail handle sending out mails for calendar invitations etc.
and to not keep this configuration declarative.

### Setup
To set up a remote SMTP connection to Gmail servers, login to Nextcloud with
your administrator account, go to `Administrator settings` -> `Basic settings`
-> `Email server` and set the following fields:

`Send mode`: `SMTP`\
`Encryption`: `SSL`\
`From address`: `youraddress` @ `gmail.com`\
`Server address`: `smtp.gmail.com`:`465`\
`Authentication`: `on`\
`Credentials`: `your_address_without_@gmail.com`\
`Password`: `your_generated_app_password`\

> [!TIP]
> You can generate the third party password by going to the following link:
> https://myaccount.google.com/apppasswords

Finally, test out if the mail server responds by clicking `Send email`.

# VPN through Wireguard

I currently have 2 VPN tunnels set up that I can use with both my main laptop and my phone to
* add another layer of encryption while using non-trusted networks
* bypass content restrictions
* access services only open to LAN

For setup generate the keys for all machines, copy `hosts/[hostname]/wireguard.nix` and
edit the peers, copy and fill in the client configuration located in `env-template/wireguard/client_template`,
install a Wireguard client (e.g. [Wireguird](https://github.com/UnnoTed/wireguird)) and add the template. Refer to [this](https://alberand.com/nixos-wireguard-vpn.html) or [this](https://markliversedge.blogspot.com/2023/09/wireguard-setup-for-dummies.html) guide for further help.


# Recursive DNS resolver Pi-hole

Hosting my own DNS server [Pi-hole](https://pi-hole.net/) allows me to block ads more effectively on platforms, where
easy and convenient ad-blocking features are unavailable (e.g. mobile apps). This in turn makes
DNS queries and website loading faster. Compared to only using a browser extention, the queries
aren't sent outside the local network and the resources aren't loaded before being blocked by the extention.

> [!TIP]
> Set both the DNS servers to the static IP of your server in your router's admin interface,
> otherwise ad-blocking won't be so effective.

> [!NOTE]
> If your server becomes unavailable, DNS queries won't be resolved.


# Cloud printing

The [CUPS](https://openprinting.github.io/cups/) backend, combined with the [SMB protocol](https://docs.oracle.com/cd/E18752_01/html/819-7355/gfhaq.html) allows you to advertise your printer to
the local network. This means that anyone who is connected to your LAN will be able to see and
use your printer without any configuration or drivers required on their part.

The [NixOS wiki](https://nixos.wiki/wiki/Printing) has a well-documented entry for configuring a network printer.

> [!TIP]
> If the setup isn't working, check if the cable is properly connected to the printer to avoid headaches.

# Monitoring

Since I manage two servers, ensuring fault-tolerance and monitoring them is crucial.

The data on both servers is stored on 3 externally attached 500GB SSDs that are in a RAID-Z1 array,
which is functionally equivalent to a RAID5 array (one SSD of redundancy). With this I get almost
1TB of usable space.

Monitoring happens with [Uptime Kuma](https://github.com/louislam/uptime-kuma). With help of *systemd timers*, the servers ping each other and
also make sure one of the SSDs haven't failed. If something happens or the other server doesn't respond
in time, a notification is sent to me on Discord.

Having a VPN also allows me to remotely access router settings, in case it's necessary or to tweak
port forwarding.

# Word of caution
Do **not** forward any more ports on your router than you **have** to. Only expose the services you need
access to outside the home network (e.g. NOT a cloud printer).

> [!NOTE]
> If you set up a VPN, you can access all of the services available on LAN outside
> of it while ensuring no one else can access them.

The only ports I have forwarded on my router are:
* `Port 80 (TCP)` for [Let's Encrypt](https://letsencrypt.org/) TLS certificates
* `Port 443 (TCP)` for hosting Nextcloud (password-protected)
* `Port 6968 (TCP)` for SSH (pubkey authentication)
* `Port 39999 (UDP)` for the Wireguard VPN

# Troubleshooting

> `acme-${domain}.service` failed while rebuilding the system.

You may need to disable `Always Use HTTPS` in Cloudflare's dashboard and turn off the proxy temporarily.

