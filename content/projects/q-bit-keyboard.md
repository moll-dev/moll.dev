---
title: "Designing and Building My Own Keyboard"
date: 2015-06-05T15:23:31-07:00
tags: [design, electronics]
draft: false
---

_Disclaimer: This post is a retrospective. I originally wrote about this on thomasmoll.co, which is now defunct._

<blockquote class="imgur-embed-pub" lang="en" data-id="a/t4DKl"><a href="//imgur.com/a/t4DKl">Q-bit | Custom 60% Keyboard build</a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>

# The Setup
<span class="drop-caps">I</span> started this project after my sophomore year of college at Iowa State University. I was a few weeks in to my second internship at Garmin on the Automotive OEM team and I was getting more and more into mechanical keyboards. I had seen some people designing and building their own from scratch, so I decided to try my hand at it. Unfortunately I'm typing this on a Pok3r, a keyboard which is much, much better than the one I made. 

I knew I wanted a 60% keyboard, a type of keyboard which lacks the navigation arrows and number pad. Instead of moving your hand from one section of the keyboard to another, you simply use macros to "shift" into a different mode. For instance, right now I have the `CAPS LOCK` key mapped as my meta key, holding it turns the keys `I` `J` `K` and `L` into the arrow keys Up, Left, Down and Right respectively. Perfect for long days at a terminal when you don't want to be constantly readjusting your fingers. I'm a touch typer, meaning I don't look at the keyboard when I'm typing / programming. It also means you have less distance to move your arm when using the mouse again. 

# Avoiding CAD
The first step to any hardware gadget design: what the hell is going to hold all my electronics? For typical keyboards they'll have a plastic or metal clam shell which encapsulates a PCB (printed circuit board) which has either mechanical switches or rubber domes layered on top. Then the keycaps fit onto the plastic stems on the switches. 

For my keyboard I went with a basic top plate to hold the switches, and a bottom plate to keep it all in place. I found a neat website to auto-generate CAD layouts called [swillkb](http://builder.swillkb.com/). That summer I was fortunate enough to have a family friend named Gary who does consulting work as a master machinist in retirement. In his garage he has a Personal CNC, Rotary Lathe, 3d Printer and all the tools you could ask for. I told him about the job I wanted to do and he helped me setup the toolpath, walked me through how to setup my work piece, select an endmill and kept tabs on the machine for any chattering.

{{< inset_image src="https://i.imgur.com/qvjk7bL.jpg" title="Working hard on the CNC" >}}

I can't thank Gary enough, he took a Saturday to mentor me and pass down some really important skills I wish I used more often. We were able to mill the front and back plates with relative ease, after all I had a master mechanical engineer looking over my shoulder. In hindsight, this is really a better task for a plasma cutter or even better a water jet cutter. The CNC machine uses rotary bits to cut away material, and we had to use three different passes with smaller and smaller bits to carve out the corners. Typically you'd use an 1/4th inch bit, then a 1/8th inch and so on until the work piece was finished.

# Getting Wired

On to the next step, hand wiring. Since I didn't feel like getting into PCB production for this build, I decided to hand wire each row. The electrical layout uses 5 rows and around 14 columns to make a 2d matrix of possible key presses. The microcontroller sends a pulse out on each row, detecting which column connects the circuit. It does so with a relatively simple diode setup, preventing current from flowing backwards. 

{{< inset_image src="https://i.imgur.com/8BoQDT8.jpg" title="M A T R I X" >}}

I originally live streamed this on Twitch.TV, fortunately for me, some viewers pointed out that I was soldering the plate backwards, meaning I had to desolder the entire thing and flip the switches to the opposite side... Anyways, 6 hours later I had the thing soldered up to my microcontroller of choice, the Teensy. Had this been in 2018, I could have soldered a Raspberry PI Zero W to it and had a portable linux computer, it's really amazing how times change. 

Programming was done via [TMC](https://github.com/tmk/tmk_keyboard/), fortunately configuration is relatively simple, debugging is a bit hard, since you're testing the hardware AND software together. I had a few keys stuck on, making it hard to test on the same computer you're programming on when your rogue keyboard is typing "ggggggggggg" 20 times a second. 

TMK makes keymaps easy with a _GIANT_ macro:
{{< highlight julia "linenos=table" >}}
#define KEYMAP( \
    K31, K30, K00, K10, K11, K20, K21, K40, K41, K60, K61, K70, K71, K50, K51, \
    K32, K01, K02, K13, K12, K23, K22, K42, K43, K62, K63, K73, K72, K52, \
    K33, K04, K03, K14, K15, K24, K25, K45, K44, K65, K64, K74, K53, \
    K34, K05, K06, K07, K16, K17, K26, K46, K66, K76, K75, K55, K54, \
         K35, K36,           K37,                K57, K56 \
) \
{ \
    { KC_##K00, KC_##K01, KC_##K02, KC_##K03, KC_##K04, KC_##K05, KC_##K06, KC_##K07 }, \
    { KC_##K10, KC_##K11, KC_##K12, KC_##K13, KC_##K14, KC_##K15, KC_##K16, KC_##K17 }, \
    { KC_##K20, KC_##K21, KC_##K22, KC_##K23, KC_##K24, KC_##K25, KC_##K26, KC_NO    }, \
    { KC_##K30, KC_##K31, KC_##K32, KC_##K33, KC_##K34, KC_##K35, KC_##K36, KC_##K37 }, \
    { KC_##K40, KC_##K41, KC_##K42, KC_##K43, KC_##K44, KC_##K45, KC_##K46, KC_NO    }, \
    { KC_##K50, KC_##K51, KC_##K52, KC_##K53, KC_##K54, KC_##K55, KC_##K56, KC_##K57 }, \
    { KC_##K60, KC_##K61, KC_##K62, KC_##K63, KC_##K64, KC_##K65, KC_##K66, KC_NO    }, \
    { KC_##K70, KC_##K71, KC_##K72, KC_##K73, KC_##K74, KC_##K75, KC_##K76, KC_NO    } \
}
{{</ highlight >}}


Due to the bespoke design, troubleshooting was easy, yet fixing involved desoldering and unwinding a beautiful spiderweb of signal wire.

{{< inset_image src="https://i.imgur.com/OudezzY.jpg" title="So Bespoke" >}}

After a few hours and a few soldering iron burns later, my keyboard was in a working state.


# Action shots

{{< inset_image src="https://cdn.moll.dev/static/images/projects/q-bit-keyboard/20150821_180542_HDR.jpg" title="Me in 2015 using my keyboard with my Surface Pro 3" >}}

I actually did end up using the keyboard, unfortunately due to some shift key problems, it was never my daily driver. For a first attempt, I think it turned out pretty good! The project overall was a vehicle to learn something new and build on my Computer Engineering skills from school.

