# CaffeinatedOpe's Infrastructure as Code
## because i already forgot how i set up my homelab

Homelabs are awesome. However, I have the memory of a goldfish, so remembering how to make a change after I've done it a few weeks ago, or even a few minutes ago, is a herculean task. The solution: write down all the settings I need, then re-use the same five or so commands to make those changes. While most people would call this solution lazy and overcomplicated, a small group of people who call themselves "sysadmins" call the concept "Infrastructure as Code", which is significantly cooler sounding. One slight issue with using this term is that it tends to involve the creation and initialization of virtual resources from a cloud provider, but I'm going to prevent that from being an issue by ignoring it entirely.

## The Mess I've Made:
I've structured things in a way that's only slightly confusing to me. Before I explain the software side, I'm going to explain the hardware, so things might sound less foolish. I've got 3 identical machines, all running with 8gb of ram, 4 only slightly geriatric cores, and 128gb ssds. While this setup would've been considered underpowered and cramped when it comes to the ram and storage, the blessing of a ram crisis makes it Almost Reasonable™.  
Now that the thinking rocks are explained, onto the fun part: the software side, which needs a college degree that I don't have in order to fully understand.

* Base OS: [NixOS](https://nixos.org/)
	* NixOS allows for the entirety of an operating system to be defined via a config file, which is nice when you're trying to configure an entire server system via config files.
	* While not *quite* fully headless, [NixOS Anywhere](https://github.com/nix-community/nixos-anywhere) allows a user to install and deploy a NixOS config over ssh. You do need to set a root password for an installer of your choice, likely the default NixOS installer, but that's easy to do without a monitor, and would be easy to program a BadUSB script for if I cared enough.
	* Disks get configured through the Nix config using something I don't remember the name of, but it's in the NixOS Anywhere repo if you're curious. Each node runs the same programs, with some slight changes per node to change whether it's initializing or joining a cluster, and to change the hostname. These differences are managed through Nix flakes, which is a whole rabbit hole I'm not caffeinated enough to explain.
	* Secrets in the OS are done with [sops-nix](https://github.com/Mic92/sops-nix), because while there is no perceivable way to use my cluster join token for evil, or at all, I'd rather not be open to attacks when someone hacks my router and extinguishes my firewall. While this works, it does mean that you need to manually copy over a keyfile, which can be done via an option from NixOS Anywhere. I added an overlay folder to drop the file in exactly the right directory, but left the actual key file out for obvious reasons. There's plenty of documentation in the sops-nix repo, so you can get up and running there.
* Containerization: [K3S](https://k3s.io/)
	* This was a pretty easy/lazy choice, since I wasn't aware of any options that were as easy to get up and running, and I had too few complaints to bother looking. Tools exist to initialize these clusters, but I used the Nix configs I was already deploying, which works as well as intended.
	* The bootstrapping token was kind of a pain to get set right. I had to boot up the initial node with a random token, generate a new one, then update the initial node with the new token, and install the other nodes with that new token as well. A bit finnicky, but once it works, it works.
	* To get network traffic in and out of the server, I had to decide between a few different options. K3S's networking has load balancing by default, so I wouldn't need to worry about it and could port forward from just one node. However, I had this foreign desire to do better, so I looked into ways to tunnel the traffic out of the entire cluster, rather than a single node that could knock the whole cluster offline when I trip over the ethernet cable. For this purpose, I decided to give [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/) a try, because it sounded good enough, and easy to implement. I was gonna use their proxy anyways.
		* While it works now, I had a hell of a time getting cloudflared to forward encrypted traffic from Traefik (more info on that in the services section). If anyone is either foolish or smart enough to try, bother me about it via an issue or dm and I'll do a writeup on how I got it working. Obviously, the config file side is already in this repo.
	* For deploying and managing kubernetes config files, I decided on [FluxCD](https://fluxcd.io). I was debating between Flux and [Argo](https://argoproj.github.io/), as I'd heard both were nice, but Flux seemed to be better for managing cluster configs. I might run Argo alongside Flux eventually, so I can use it for just compiling and deploying programs, but I've got more to do before I get to that point.
* Management Scripting: custom :3
	* Ansible exists, and some other software exists that makes it easy to auto-update nix configs. However, as the wise Adam Savage once said (more than once, really): "I reject your reality, and substitute my own". For whatever reason, I'm too lazy to figure out how to do what I need in ansible, but *not* too lazy to write a small and sparsely featured replacement for it from scratch. This script is the `multirun.sh` file, and the contents of `management-scripts/`.
	* There are only 3 commands for my management script: `deploy`, which deploys the current Nix config, `test`, which runs a few test commands, and `run`, which allows you to run a command over ssh. These operations are run on each node, and the IP of each is somewhat hardcoded out of laziness.
## The Services
Now for the part you've all been waiting for: all the nonsense I run on my lab that I really don't need to.
* Management
	* [FluxCD](https://fluxcd.io): cluster management, deployment config updates, container version auto-updates
	* [cloudflared](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/): network traffic tunneling
	* [Traefik](https://traefik.io/): ingress management and routing
	* [cert-manager](https://cert-manager.io/): certificate requests, ssl encryption
	* [Jenkins Operator](https://jenkinsci.github.io/kubernetes-operator/) and [Jenkins](https://jenkins.io): automatically builds and deploys my blog when a change is made in the git repo
	* [Reloader](https://github.com/stakater/Reloader): Automatically redeploys services when the ConfigMaps they reference get updated
* Public Facing
	* [My Blog!](https://caffeinatedope.net)
	* [httpbin](https://httpbin.org/): test site, for testing connectivity and routing
	* [Ricochet](https://github.com/CaffeinatedOpe/ricochet): My link shortener and redirector, designed for kubernetes, and built in rust.
* Fun Stuff
	* none... i'll get to it eventually

## the //TODO list:
I've gotten a lot done, but there's so much more to do. Here's the ones I've remembered to write down:
- figure out some sort of volume management, preferably aside from just nfs
- migrate arr stack, media hosting, photo library, etc
- figure out local dns/split tunneling, so not everything gets published to the internet, but i still have access
- tailscale. just tailscale. i've got headscale running on my nas (also runs everything else of mine, but not documented), and have access to it through my nas's exit node, but I i should find a better way to integrate it with the cluster.
- logging, i've heard grafana is cool, but haven't set it up yet
- ~~blog hosting... this should probably be at the top of the list, but yknow. I need to set up not only hosting for the blog, but also set up a ci/cd pipeline to automatically update it whenever i push a new version.~~ Done!
- github alternative? there's the issue of, well, issues when it comes to git hosting. either I open up accounts to anyone, or nobody can create issues or pull requests. i'll look into it eventually, probably while I've got more important things to be working on.