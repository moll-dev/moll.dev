---
title: "Growing up with Minecraft"
date: 2019-08-18T15:58:49-07:00
tags: ["life"]
draft: false
---

If I were to rank the hours invested in something so far in my life, first is Computer Engineering, second is Minecraft. Unfortunately, I don't play much since college; Minecraft is a game which tends to draw you into the early hours of the morning. Something I would regularly do in high school, eschewing my homework and exploring virtual worlds built by other kids just like me, making friends, and learning digitial logic on accident.
<br>
<hr>
<p class="f5">
For those who haven't heard of, or played, Minecraft. It's a voxel (block) based survival game. You start out with nothing, collect resources, craft tools and explore caves. The game has a day / night system which spawns more monsters for you to fight. In recent years, Mojang, the active developers of the game, have added more systems such as villages, different realms, and new types of biomes. In addition, Minecraft has a very active playerbase populating thousands of custom servers. 
</p>
<hr>

# Dirt

Growing up, my parents tried to restrict my exposure to video games. They would much rather I played outside or made something. As you might imagine, I didn't have access to a super powerful gaming computer either, I was limited to an old work laptop my Dad used in the early 2000's. It was _supposed_ to run Windows XP, but I had reinstalled it with Mint Linux to actually make it usable. I had a blast with free software like GIMP and Blender, even though the latter took 8+ hours to render a single frame. 

I was a freshman in high school at the time. A friend came up to me after class and asked if I was playing a new game called Minecraft. He gave me instructions to log onto a specific server and proceeded to give me detailed instruction on how to get to his hideout. We didn't really have high speed internet at my house, so I went to the library to look up some videos. 

In these days, kids only went to the library to get on the computers. Desktop computers were still expensive and laptops even more so. The library was the place to get onto the internet, sites like "Albino Black Sheep", "Newgrounds", "AddictingGames" and "FunnyJunk" were in everyone's bookmarks. The game Runescape was also fairly popular, all you needed was a web browser and you'd have access to a massive 3d MMORPG. 

The early days of Minecraft were mainly web based, as the game relied on a Java browser plug-in to run. All you needed was an account, and a browser and you could play. No disks, no installation, no parents bugging you to uninstall the game because it was "making their computer run slow". I made an account, paid the 12$ admission fee and fell down the rabbit hole.

At first things were simple: punch some wood, mine some stone, make tools, then food, then weapons, then torches for exploring, then make a chest to store your ore, then a house to store your chests, then a minecart track to go between your houses. Minecraft places you firmly in the driver seat, no quests, no story line, no poorly voice acted NPCs. Just you, your imagination and in infinitely generating world.

And I was going try my dammnest to explore all four corners of that world.

# Diamonds

After getting my bearings in a single player world, I decided to join my friend online. I texted him for the server details again, logged on and followed him to his hideout. He taught me the best way to mine for diamonds, a rare resource in the game. Playing an unstructured game with a friend is the best experience, being in a large sandbox with no rules, or restrictions brings out the creative side in everyone. 

We spent hours and hours playing. We would raid other player's bases for loot, fight zombies, explore the Nether, which was a recent addition at the time. We dug out massive underground caverns for farming enemies (better known as mobs) for easy loot. The only bad thing about playing on custom server. Typically they're hosted with someone's parent's credit card, a recipe for disaster. 

One day after class, we got on Minecraft and tried logging into the server. No dice. Server Timeout. We checked the MinecraftForums where server operators would post new servers and updates. Sure enough the operator explained his parents had found out he paid for 9 months of server time and got in trouble. Ephermerality is a keep meta-game in Minecraft. Counter to the internet, nothing is permanent. We had lost dozens of hours of work, but I could care less, we had dozens more hours ahead of us to rebuild.

While waiting for my friend to find a new server, I stumbled upon a section of the Minecraft Forum titled "Redstone". It's a system in Minecraft that lets you simulate electrical signals. Other players would post various contraptions, ranging from automatic cow farms to fully fledged computers. My first thought, like anyone, was "how the hell do you make a computer in Minecraft??". After reading a couple threads and trying a few logic circuits in game I dove headfirst into it. Unfortunately the first few hours were rough, I kept searching for "physical logic", you know because circuits are physical? Once I realized my mistake, I was inundated with content, mainly university course slides. I learned binary, then basic logic circuits, then latches and sequential logic. Hell, I even learned DeMorgan's law. 

# Redstone

A few months go by, I've been honing my digital logic skills, shirking my high school responsibilities. I've learned about muxes, demuxes, encoders, ROM, RAM, even basic ALU design. I decided it was time to actually build something. I landed on creating an automatic bank vault. At the time, modding in Minecraft was mostly limited to single player, there were some mods to protect sections of land and other basic admin tools. When playing with other people on a public server, you can guarentee that someone will steal your stuff the moment you log off. Hiding your loot is difficult when someone can dismantle your entire base in an hour. My solution was to create a pin protected central bank, one that an admin could lock users from destroying the circuitry, but still use the buttons and levers. 

I had recently discovered a tool called Logisim, developed by Carl Burch a Carnagie Mellon PhD. It allowed you to simulate relatively complex logic circuits. This greatly increased my speed as I didn't have to look up and construct all the Minecraft incantations for XORs and others. I prototyped for about a week. I had a 9 digit keypad, a binary encoder, some RAM for storing user passcodes (4x4bits) and XOR comparitors. I really wish I had the original schematics. The trickiest part was figuring out how to scan through the RAM page by page to compare each number of the pin. It's a clockless design, which works well in Minecraft due to a 15 block limit on signal transmission creating a lot of clock skew. I took the next month to craft the circuit in game.

As in the real world, space is a constraint, especially when dealing with a lot of signals. You can see in my first attempt:
{{< youtube 0E1_U08CpbU >}}

Fortunately I decided to capture this in a Youtube video on my newly "upcycled" Mac book from my Dad's work. If you're wondering, yes I still cringe when I listen to this video. I also provided an explanation video, which honestly still holds up.

{{< youtube 91vPyI2YXM0 >}}

2 years later, I went back and revisted the design. The circuitry is the same, but with smaller version with modular RAM. The presentation style is also a bit cleaner. Apparently I also went through puberty between 2011 and 2013 if you listen carefully. 


{{< youtube kqPBM0m97PU >}}

To this day, I'm still really proud of this project. It made my first "real" digital logic course in college a breeze. I literally aced every exam. There's something special about having a self driven project and digging all the way down to understand each and every aspect. It's the project that solidified my autodidactic approach to interesting problems. 
