---
title: "Building a DIY 72TB NAS"
date: 2023-08-08T11:26:54-07:00
tags: []
draft: false
---

<img src=/images/nas/IMG_8479.avif class="center">

## Table of contents
- [Parts List]({{< relref "#parts" >}})
- [Build Steps]({{< relref "#build" >}})
- [Addendum - Modifications]({{< relref "#mods">}})

For someone in Site Reliability Engineering, my job is all about creating scalable, reliable, large scale systems. I worked on LinkedIn's Hadoop team helping to scale our HDFS capacity to [over an exabyte!](https://engineering.linkedin.com/blog/2021/the-exabyte-club--linkedin-s-journey-of-scaling-the-hadoop-distr). You _would_ think that my home storage setup would be highly-available, redundant and geographically distributed. Unfortunately, my only _homelab_ equipment is a Raspberry PI "colocated" in a cardboard box with an Nvidia Jetson hooked up to a USB hard drive. 

<img src=/images/nas/IMG_8403.avif class="center">

Recently, my wife and I got married, and we were sent a download link for a huge archive with all our photos and videos. Just downloading them to my desktop didn't seem fitting; these are super special photos to me, I should take more care in storing them! Over the years when I would get a new phone, I would take backup my old phone's photos and videos, putting them in a random folder on an external HDD. While I have some of these backups, I realized that Google Photos wasn't working for months at a time, and I had lost photos from high school and college. Videos I had made with my friends over the years were hosted on Facebook or Youtube, but what if those services went away? I would have zero recourse in getting them back. 

Those memories are priceless, and worth far too much to trust entirely to someone else.

I started looking into NAS systems. NAS stands for Network-Attached-Storage and it's effectively a dedicated computer responsible for managing files and making them available over the network. Although many modern NAS systems are more than capable to host other services for hosting a mesh VPN, DNS, email, and many more services.

I first looked at off-the-shelf NAS systems, stuff made by Synology and others. You buy it, plug it in, plug some drives in, and you've got a NAS. Somewhat expensive for what you get, but since you're reading this on [moll.dev](moll.dev) you know where this is going next 😉, I decided to build my own.

Now, I could go over all the reasons to DIY vs Buy, but they're boring, and my answer is always going to be _it's more fun to DIY shit_. I love picking out parts and building stuff, if I can help it. 

Here's some functional requirements for my NAS:
- Lots of storage 
- Reliable
- Repairability
- Ability to self-host services

Non-functionally:
- Uses consumer hardware - potentially less reliable, but more readily available.
- Quiet - this machine is going to run in my home office, not a datacenter.
- Low Power consumption - this machine is going to be running 24/7 and I'm paying for power.
- Aesthetically pleasing - I _hate_ black box home lab stuff, especially if it's going to be visible in my home.
# The Parts {#parts}

<img src=/images/nas/IMG_8439.avif class="center">
<hr/>

| Part                           | Component        | Price USD |
| ------------------------------ | ---------------- | --------- |
| [CWWK J6413](https://www.amazon.com/dp/B0BZ71JRX3?psc=1&ref=ppx_yo2ov_dt_b_product_details)                   | Motherboard      | $189      |
| [Jonsbo N2](https://www.amazon.com/dp/B0BQJ6HHXJ?psc=1&ref=ppx_yo2ov_dt_b_product_details)                | Case             | $150      |
| [WD Black 500GB NVMe M.2 ](https://www.amazon.com/Black-SN750-WDS500G3X0C-500GB-PCIe/dp/B07Q8VXYLG/ref=sr_1_2?crid=3S8AELC4JZ7ZA&keywords=wd+black+500+nvme&qid=1691095190&sprefix=wd+black+500+nvm%2Caps%2C141&sr=8-2&ufe=app_do%3Aamzn1.fos.006c50ae-5d4c-4777-9bc0-4513d670b6bc)(x2)   | OS Drive         | $60       |
| [Lian Li SP 750W](https://www.amazon.com/White-Color-Performance-Factor-Supply/dp/B0B19CLDP2/ref=sr_1_2?crid=38YR8KNLKWTC7&keywords=Lian+li+sp750&qid=1691095223&sprefix=lian+li+sp750%2Caps%2C151&sr=8-2&ufe=app_do%3Aamzn1.fos.f5122f16-c3e8-4386-bf32-63e904010ad0)                | PSU              | $109      |
| [Crucial (2x16GB) DDR4 3200MHz](https://www.amazon.com/Crucial-2x16GB-Laptop-Memory-CT2K16G4SFRA32A/dp/B08C4X9VR5/ref=sr_1_1?crid=3E2SEQWH15QES&keywords=crucial+ddr4+3200+32gb&qid=1691095244&sprefix=crucial+ddr4+%2Caps%2C163&sr=8-1)  | RAM              | $57       |
|                                |                  |           |
|                                | Total            | $565      |
|                                |                  |           |
| [Seagate Exos Pro 18TB HDD (x5)](https://www.amazon.com/Seagate-ST18000NM000J-Internal-Surveillance-Supported/dp/B08K98VFXT/ref=sr_1_5?crid=BU9L944OPKOC&keywords=Seagate+exos+18tb&qid=1691095279&sprefix=seagate+exos+18t%2Caps%2C149&sr=8-5&ufe=app_do%3Aamzn1.fos.c3015c4a-46bb-44b9-81a4-dc28e6d374b3) | Data Drives      | $825      |
|                                |                  |           |
|                                | Total w/ Storage | $1,390    |
<hr/>

## Motherboard + RAM
I went with the CWWK J6413 also known as the "Topton", a purpose built NAS motherboard by a company out of Shenzen. You can find this board on AliExpress with some sellers drop shipping them through Amazon. 

<img src=/images/nas/IMG_8453.avif class="center">

This board will do it all, it has an [Intel Celeron J6413](https://www.intel.com/content/www/us/en/products/sku/207909/intel-celeron-processor-j6413-1-5m-cache-up-to-3-00-ghz/specifications.html) which can turbo up to 3.00 Gz, it also has an Intel iGPU for hardware video transcoding. More than enough to host files and powerful enough to run numerous Docker containers for other fun services. 

A word to the wise about buying unbranded hardware from China: expect zero support out of the box. You _will_ be relying on forums and other people to get support for this board, if you're lucky and get a sales email from the original supplier, they _can_ be amenable to helping you out. Don't expect the GeekSquad white glove experience here. 

RAM wise: literally nothing to write home about. It's DDR4 laptop ram, 32GB is more than enough to run some Docker containers.

## Case + Power 
Literally anything could work as a case, as long as it has enough hard drive bays. Throw this in an old PC case if you'd like and save the $150. I'm a particular individual and just enjoy cool looking things, so I went with the most IKEA type home lab I could find. 

<img src=/images/nas/IMG_8430.avif class="center">

The Jonsbo N2 is a joy, it's bigger than its younger brother the Jonsbo N1, with a lot more space to build in. It's got a hotswap backplane for hard drives, supports Mini-ITX motherboards, SFX power supplies and looks very cute in white. Again, Jonsbo is a small brand, but hey it's a hunk of metal.

<img src=/images/nas/IMG_8442.avif class="center">

The PSU I went with is the Lian LI SF750. It's a small form factor PSU with a frickin' [Platnium Power rating from Cybernetics' test lab](https://www.cybenetics.com/index.php?option=database&params=1,0,79).  The main reason I went with this one, it's efficient as heck, especially for low (<30W) usage, it's passively cooled until 200W meaning the fan will almost never kick on, and it matches my case. Enough said.

## Storage

<img src=/images/nas/IMG_8000.avif class="center">

As this is build is effectively a mini computer slapped onto a pile of hard disks, I had a ton of choices. There are plenty of guides on how to pick out a consumer drive, where to find them for cheap, etc. However, the deal of the century dropped into my lap for some 18TB Seagate Exos Enterprise drives and I _HAD_ to buy them. Actually, I might buy even _more_ because it was such a great deal. A local UNIX wholesaler had a ton of them refurbished from a data center that had over ordered drives. They only had 60 hours of power-on-time too.

With a ZFS `vdev` mirroring setup, this gives me a whopping 32TB of space at $22/TB Insane.
[Link to ZFS calculator](https://wintelguy.com/zfs-calc.pl)

<img src=/images/nas/zfs_calc_1.avif class="center">

Since my case only holds 5 HDDs, I went with a 4 drive + 1 cold spare setup. The 4 hot drives are split into two _mirrored `zdevs`_ which is where two devices effectively act as one doubly redundant 18TB hard disk. Add two of these together and subtract for ZFS redundancy, etc. You get 32TB with the ability to support 1 disk failure (or 2 if you're lucky). I specifically chose mirrored `vdevs` over ZRaid N1 or N2 because the time to rebuild is _much_ faster. I can just swap the extra HDD into my chassis, and recover, hopefully before another drive dies.

<img src=/images/nas/IMG_8447.avif class="center">

Operating System drive wise, I just went with two cheap M.2 NVME 500GB WD Drives in a RAID1 configuration, plugged into the motherboard. I can lose one drive, replace it and keep my system up and running. Super cheap, fast, and ubiquitous in case of failure. 

## Enzovoort
_(et cetera in Dutch)_

<img src=/images/nas/IMG_8450.avif class="center">
<img src=/images/nas/IMG_8452.avif class="center">

Of course anything worth doing is worth over-doing. I've also purchased a few extras that will make this build a bit nicer to build and improve the thermal performance along with keeping it quieter.

In no specific order
- Noctua 60x25mm 12v Fan
- Noctua 120x25mm 12v Fan 
- [Server style 6x SATA connector](https://www.amazon.com/dp/B0B1CZHXZ1?psc=1&ref=ppx_yo2ov_dt_b_product_details)
- [M.2 Heatsinks](https://www.amazon.com/dp/B082VTVP51?psc=1&ref=ppx_yo2ov_dt_b_product_details)
- 40mm x 12mm MOSFET Heatsinks

If you've got the extra money to spend (~$100), I would recommend these upgrades.

# The Build {#build}

Now that we've got our parts, let's get to building. If you've build a computer before this will all be super familar. However, with a smaller case there's some necessary order of operations for cable routing.

## Step 1. Install PSU and cables

I first got the necessary power cables routed. A single 24pin CPU connector, an additional 4pin CPU connector, and a Molex accessory connector for the drive backplane. 
<img src=/images/nas/IMG_8455.avif class="center">

I then routed the SATA cable bundle from the backplane in the bottom of the case up to the top part of the case.

<img src=/images/nas/IMG_8459.avif class="center">

## Step 2. Install RAM + SSD with Motherboard

Next, I mounted the SSDs in their heatsink cases, and then mounted them to the motherboard.
I seated the RAM into place as well. After putting in the motherboard I/O plate, I mounted the motherboard into the case, attaching only the power button and power LED cables from the front panel (this board doesn't have an internal USB3 header or audio header anyways).

<img src=/images/nas/IMG_8478.avif class="center">

I then plugged in the power cables and SATA cables into the board. Cable routing as necessary. 


## Step 3. Install Hard Drives

We're almost done! Now to install the case provided mounting grommets and handles onto our HDDs, allowing them to slide into the front of the case and click into the back plane. It's tool-less so you can hot swap drives without having to turn the system off!

<img src=/images/nas/IMG_8462.avif class="center">

And now we're ready for first boot!
<img src=/images/nas/IMG_8465.avif class="center">

From this point, I installed Ubuntu 22.04 LTS from a flash drive and got to work setting up the system. I'll probably write up my installation experience at some point in the future, but considering most people will just install TrueNAS or Unraid, this is kind of a niche setup anyways.

That's it for this build, thanks for reading! Stay tuned for some benchmarking numbers once I settle on what software I want to use. If you're interested in the additional modifications I made to this build, feel free to continue reading.

# Addendum - Modificatiosn {#mods}

While this section isn't strictly necessary, I decided to go the extra mile to ensure my system would be cool and functionally silent. These mods will require access to a dremel, 3D printer, and some basic fabrication skills

## CPU Heatsink Noctua Mod

According to forums posts from others who purchased this board, the default heatsink and fan can cause thermal throttling while under load. Meaning the CPU will down clock to prevent any long term damage. As this system will be running 24/7 I don't want to risk any additional heat prematurely compromising this board. 

### Heatsink Modifications
I unscrewed the heatsink + fan combo, cleaned the CPU, sanded and lapped the underside of the heatsink (probably unnecessary), and applied new thermal paste. I removed the stock fan from the heatsink as well.

<img src=/images/nas/IMG_8414.avif class="center">

I then cut a 40mm aluminum heatsink down and used thermal glue to fill the space of the small fan.

<img src=/images/nas/IMG_8420.avif class="center">
<img src=/images/nas/IMG_8421.avif class="center">
<img src=/images/nas/IMG_8423.avif class="center">


### Noctua Fan Mounting

I _carefully_ drilled pilot holes in the plastic heatsink shroud. I took some 3MM radiator screws and self tapped them through the new Noctua 60mm fan's mounting holes. I had to take a dremel to the underlying heatsink to get clearance for these bolts.

<img src=/images/nas/diagram.png class="center">

<img src=/images/nas/fanmount.png class="center">

This new fan is a lot more quiet, and keeps the CPU cooler. Honestly knowing Noctua, this fan will probably outlast this entire system.

## Case Fan Mod

<img src=/images/nas/IMG_8518.avif class="center">

For the case, the Jonsbo N2 only has one casefan at the rear. This fan needs a high static pressure because it's pulling air across the large front grill, along the HDDs and out the back. Unfortunately the case is too shallow for a full size (25mm) fan. I found a [3d printable](https://www.printables.com/model/526778-jonsbo-n2-extended-fan-module) adapter that lets you put a quieter and higher performance fan on the back! I printed it off, and fitted it to the back. 

<img src=/images/nas/IMG_8517.avif class="center">
<img src=/images/nas/IMG_8520.avif class="center">

One thing to note, this fan runs off the SATA backplane's power and runs at full speed all the time. I replaced the stock fan with another Noctua fan because they provide adapters to control the speed manually.
