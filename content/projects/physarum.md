---
title: "Generative Art and Biology: Creating Life Through Computation"
date: 2021-02-23T01:25:54-08:00
tags: ["art", "julia", "gpu"]
draft: false
---



{{< better_vimeo 503644203 >}}
{{< sticky id="2" content="Scroll through the entire post for more neat animations!" >}}
<br>

Computer graphics have been an interest of mine for as long as I've used a computer. The ability to create life like renderings has always held my captivation in one way or another. I grew up using open source graphics software like [GIMP](https://www.gimp.org/) and later [Blender3D](https://www.blender.org/). I fondly remember letting the family laptop run all night rendering frames for a 3D animation I had made in Blender for school. Being able to _theoretically_ produce photorealistic images like Pixar or Lucasfilm made me feel like I could create my own reality, only given enough time and patience. Instead of going to school for animation, I hedged my bets on studying Computer Engineering, learning _how_ the computer worked rather than learning how to use the suites of programs to their fullest. Throughout university I kept up with computer graphics by reading SIGGRAPH papers, watching the talks, and trying to implement some basic graphics programs myself. 



Inherently, computation is often seen as uncreative. Systems are often purpose designed for a singular task: serve this web resource, convert this file, send this message. Certainly artists use computation to complement their vision, like a traditional artist would use with paint on canvas. This process still requires a large amount of input from the human artist: laying out compositions, selecting pallets, and tweaking lighting. What if a computer was solely responsible for the generation of the forms traditionally created by an artist? Writing code is a creative process, but can we design our code to be creative? Generative art puts the relationship between artist, programmer, and concept front and center. [Manfred Mohr](http://www.emohr.com/), one of the original generative artists, states succinctly in his interview in [_Computing Europe_](http://www.emohr.com/ww2_out.html) 1974:

<blockquote class="">
    <p class="f2-ns lh-copy lh-title-ns f3 tj">THE MACHINE SEEN AS AN EXTENSION OF US.
    </p>
  </blockquote>

His primary thesis being that the computer is a perfect tool for not only artists but everyone. This was a forward-looking view in 1974 as the computer is no longer a beige box sitting on a desk in our households, it has been integrated into nearly every facet of our lives, even so far as to be come a companion that we rely on constantly. We can extend ourselves reflexively into the digital realm, despite not understanding all the behind-the-scenes operations. Mohr envisions the artist's relationship to computer systems as a dialectic one: we propose a _thesis_ to a computational system, it responds with a generated _anti-thesis_ and the cumulative outcome of this process many times over is the _synthesis_ or final piece. A discourse, an iterative feedback loop revisited many times over in search of a common truth. Generative art is the combination of our messy, leaky, subjective outlook and the cold, meticulous computing of a machine.


# THE IMITATION GAME

{{< better_vimeo 495433594 >}}

In some previous work where I [modelled Reaction Diffusion systems with Julia](https://www.moll.dev/projects/reaction-diffusion-julia/), I explored the emergent organization of two simulated _chemicals_. Small variations in chemical _feed_ and _kill_ rates produce a large variation in overall structure and behavior at different scales. I use the term _emergent_ here because structures _emerge_ from random noise, the code is naively computing frame after frame, unaware that it's producing such organic results. The term _emergent gameplay_ refers to the complex situations that are produced from interactions with simple game mechanics. I'm simply programming a 0-player game, and letting the rules do the rest.

A couple of weeks after I finished up my Reaction Diffusion work, I found a post by Sage Jenson, in which they outlined a process for [simulating slime molds](https://sagejenson.com/physarum) (Physarum Polycephalum). They also did an exceptional job outlining the high level implementation with some nice drawings and animations. I was instantly mesmerized by the animated ebb and flows of slime. The structures that emerged were extremely intricate, and immediately invoked imagery of veins and roots. What stood out most to me was the the varied scale of certain features within the model. Small strands and loops combine and swirl to produce larger super structures which stabilize after 100 or so frames. I was astonished when I read the full paper containing the simple rules which produced these results.

In the real world, Physarum Polycephalum is a form of acellular slime mold hailing from the protist's evolutionary tree. It typically lives on tree bark or stones in damp environments, feeding on basic food sources. Its life cycle contains many steps, however the most interesting behavior known as "Cytoplasmic Streaming", happens during the organism's plasmodium phase. This slime mold can can even solve the shortest path problem, with zero neurons. 


{{< youtube 7YWbY7kWesI >}}

Unfortunately, the authors of the slime mold paper weren't able to get their virtual slime molds to solve complex pathing problems. They focused on reproducing the slim mold's form with code, rather than precisely trying to simulate it down to the molecular scale. I was mainly interested in generating interesting forms, so I booted up a fresh [Julia](https://julialang.org/) notebook and set out creating an implementation of my own.

# AS WITH ALL THINGS, START SMALL

The paper [Characteristics of pattern formation and evolution in approximations of physarum transport networks ](https://uwe-repository.worktribe.com/output/980579) which Sage has based their work on, uses an agent based approach to approximate a slime mold's behavior. We'll start off with the concept of a _model_, which is essentially some data and rules. The data can be many things, including images, text, or numbers. The rules are the set of steps or computations needed to progress the model forward. In our case, each step represents a fixed interval of time. The model is initialized with some starting information, i.e. randomizing agents, defining parameters. We then run multiple steps, hundreds, thousands, sometimes millions of times, and observe how the data changes over time. These aren't hard and fast definitions for a model, but are generalized within the context we'll be using it.

![datamodel](https://cdn.moll.dev/static/projects/slime-mold/DataModelling3-01.png)

For our specific model, we'll start with the data. Since our model is agent-based, we'll need some common environment or world for each agent to interact with. This provides a rudimentary way for agents to _communicate_. As outlined in the paper, they use a _chemoattractant_ matrix, which I typically refer to as the _grid_. Functionally, this is just a greyscale image which each agent can "mark" to notify nearby agents. Below is a typical _chemoattractant_ matrix after running the model for a 100 frames. Where the image is brighter, there is a higher density of agents.

{{< sticky id="1" content="A snapshot of the _chemoattractant_ map or grid" >}}

![chemo](https://cdn.moll.dev/static/projects/slime-mold/data%20modellingd-01.png)

Within the code, I'm using a `CuArray{Float32, 3}` to represent this information, I'll get into why I'm using a 3D matrix instead of a 2D one later. Next, we'll need some way to keep track of each agent's position and it's direction. Here's a basic outline of how that's stored per agent. Multiple `SlimeAgent`s are appended to a list and each one is processed via the same set of rules. Each step, the agent's internal data is updated to simulate it moving and rotating.

```julia
mutable struct SlimeAgent
    x_position::Float32
    y_position::Float32
    heading::Float32
end
```

In addition, we also need a few more global parameters to define where the agent _senses_, how much it rotates towards other agents, how far it moves, and how much _chemoattractant_ it places when it's finished moving. Since these are static parameters, we just define them at the model level, defining the agent structure to be only information that's changing with respect to time. The finished agent looks something like this:

![agentanatomy](https://cdn.moll.dev/static/projects/slime-mold/agentanatomy-01.png)

They consists of a _body_ or anchor point, and three _sensors_ which are projected in front of each agent for detecting _chemoattractant_. Next, we need a set of rules to move our data from one step to the next. I've outlined the pseudo-code below:

```julia
1. Motor Step
  a. Check if agent can move forward.
  b. if so: move and deposit "chemoattractant".
  c. else: rotate in a random direction.
2. Sense Step
  a. Sample the chemoattractant matrix in three directions 
     -> front, left, right.
  b. if front sensor is the strongest: stay facing that direction.
  c. else if front is the weakest: rotate randomly, left or right.
  d. else if left is stronger than right: rotate left.
  e. else if right is stronger than left: rotate right.
```

I've broken it down into three steps in my code _motor_, _sense_ and _swivel_. First up, is the motor step:

![motor](https://cdn.moll.dev/static/projects/slime-mold/Motor%20step%201-01.png)

Each agent will check whether it's inbounds of the world, perform a basic obstacle detection check to see if any other walls are in front of it, then move forward, depositing a fixed amount of _chemoattractant_ on the _grid_. If the agent is unable to move forward, we use a "dumb" motion planning algorithm. Just spin in place until you get unstuck! Next, the agent will _sense_ its surroundings:

![sense](https://cdn.moll.dev/static/projects/slime-mold/Sample%20Step%201-01.png)

The agent samples the _grid_ three times, once in front, to the left and to the right. In the initial parameters we give the model, we describe how far and wide each agent should sample. We do a basic linear transform to get each value, taking into account the agent's heading, to find where each sensor should be. In the paper, the agent technically could sample more than one pixel of the _grid_ but in my implementation I just round to the nearest pixel and take the value directly. 

![sense](https://cdn.moll.dev/static/projects/slime-mold/Swive%20Step-01.png)

We then take the rules I outlined above and apply them to _swivel_ the agent towards the direction of highest concentration. Letting this run over many steps with a couple of agents results in some interesting behavior.

{{< better_vimeo 512387076 >}}

Each agent follows each other's trails, and tracing out new paths when they encounter the end of a specific path. I should also mention a fourth *secret* step: we also need to perform a _gaussian blur_ to diffuse the _chemoattractant_ around the map over time, this allows higher concentrations to spread out and fade overtime. 

# SCALING UP AND SCALING OUT

{{< better_vimeo 512403486 >}}

{{< sticky id="1" content="Note: I'll be using some slightly more technical language in these next sections. If you're lost, don't worry! I'll be including a ton of animations that anyone can enjoy." >}}

Now if you've read my blog before, you know what's coming next... it's time to scale up our simulation with GPUs. Unfortunately I don't have much CPU based code to show, as I nearly immediately jumped to optimizing it with GPU. Although this time I'm using a new library called [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl). It's a nice piece of kit, and allows generic kernels to be written, handling the routing between function and multiple parallel back-ends. 

First on the list, we need a _slightly_ more efficient way to store agent information. Since the GPU prefers vectorized data, I decompose the list of agents into each component `x_position`, `y_position`, and `heading`. Since the number of agents doesn't change over time, we can make a couple static vectors in memory on the GPU and update them as needed. It ends up looking like this:

```julia
struct DecomposedGPUAgents
    x::CuArray{Float32, 1}
    y::CuArray{Float32, 1}
    h::CuArray{Float32, 1}
    v::CuArray{Int64, 1}
end
```

{{< sticky id="2" content="Bug: agents were only sampling the bottom row of pixels for some reason." >}}
{{< better_vimeo 515653267  >}}

It's passed to our kernel (shown below) by a helper function to route the data to the right place. Keep in mind, every piece of data is statically allocated within GPU memory on initialization, we're just passing references around to each kernel. I also implemented a "variant" key which is used to look up an agent's specific parameters for rotation, sensing, etc. This allows me to have multiple "species" interacting with one another. It's also why I define the _grid_ as a 3D matrix, each slice contains each variant's _chemoattractant_ maps.

```julia
@kernel function motor_kernel!(x_a, y_a, h_a, v_a, obs, @Const(configs), @Const(rand_a), grids, @Const(w_s))
        i = @index(Global)
        
        v = v_a[i]
        d, c = configs[1, v], configs[2, v]
        
        # project future position, check world bounds, check obstacle map, etc.
        x′ = x_a[i] + cos(h_a[i]) * d
        y′ = y_a[i] + sin(h_a[i]) * d
        
        # LOL float32 -> int32 in GPU land
        w_idx = unsafe_trunc(Int32, clamp(ceil(x′), 1, w_s[1]))
        w_idy = unsafe_trunc(Int32, clamp(ceil(y′), 1, w_s[2]))

        if check_bounds(w_idx, w_idy, w_s) && obs[w_idx, w_idy] > 0.0f0
            x_a[i] = x′
            y_a[i] = y′
            grids[v, w_idx, w_idy] += c
        else
            h_a[i] = rand_a[i] * 2π
        end
        
        nothing
    end
```

Note the `@kernel` and `@index` macros, these are from KernelAbstractions.jl and they help to generalize kernel code. You'll notice I'm using functions like `clamp` and `ceil` have no special incantations, because they are remapped by `CUDA.jl` to the appropriate GPU functions on the hardware. We perform all these calculations agent-wise, and going through our 3 steps: motor, sense, then swivel in a similar fashion.

{{< sticky id="2" content="Here's one of my first large scale renders, with one variant and a ton of agents." >}}
{{< better_vimeo 515648204 >}}

For our fourth *secret* step, I wrote a simple box blur kernel, modifies the _grid_ in place, then multiplies by a _decay_ factor to lower the overall concentrations of _chemoattractant_.
```julia
@kernel function box3x3!(a, @Const(a_w), @Const(a_h), @Const(k_w), @Const(k_h))
        """ Super basic box blur, fixed kernel """
        g, i, j = @index(Global, NTuple)
        
        kw_off = unsafe_trunc(Int32, floor(k_w/2))
        kh_off = unsafe_trunc(Int32, floor(k_h/2))
        
        nx, ny = (i - kw_off, i + kw_off), (j - kh_off, j + kh_off)
        
        # Clamp the world neighborhood to our bounds
        nx = clamp.(nx, 1, a_w)
        ny = clamp.(ny, 1, a_h)

        a_v = view(a, g, UnitRange(nx...), UnitRange(ny...))

        a[g, i, j] = sum(a_v) / Float32(length(a_v))
    end
```

# VARIATION: THE SPICE OF LIFE

{{< better_vimeo 485032820  >}}

At this point I've worked out _most_ of the bugs, I can throw a quick color ramp (`magma` is shown above.) to make things look presentable. By all accounts, I thought I was done until I saw [Michael Fogleman](https://twitter.com/FogleBird)'s [post](https://www.michaelfogleman.com/projects/physarum/) about slime molds. He implemented a method for different variants to interact via an _attraction matrix_. Basically, we keep a separate grid for each variant, and a lookup table which weighs each variant against itself and others. An _attraction matrix_ for 3 variants might look like the following:

```julia
3×3 Array{Float32,2}:
  1.08781   -0.795218  -1.31938
 -0.958785   0.69557   -1.61444
 -1.05305   -0.502094   0.96375
 ```

Cell `[1,1]` is how _attracted_ variant `1` is to itself, cell `[1,2]` is how _attracted_ (negatively in this case) to variant `2`, and so on for variant `3`. We generate a temporary "view" or _chemoattractant_ map from each variants perspective, combining each individual map, taking into account each other variant's weight.

```julia
function attract!(model)
    # For each variant...
    for variant in 1:size(model.grids)[1]
        # Weigh each grid with it's respective variant weight.
        for other_variant in 1:size(model.grids)[1]

            factor = model.agent_attractors[variant, other_variant]
            model.temp_grid[variant, :, :] += model.grids[other_variant, :, :] .* factor
        end
    end

    # Double buffer our results.
    copyto!(model.grids, model.temp_grid)
    return nothing
end
```

Now, I must admit: I used [Michael's solution in Go](https://github.com/fogleman/physarum) as inspiration here. All that stuff about good artists copying and great artists stealing. What's to say for an inspired artist? I spent way too much time trying to figure out a proper solution on my own, and his was quite clever. He's single handedly responsible for pushing this project's deadline because I _really_ _really_ wanted to get multiple variants working. Thanks again Michael! 😁



{{< better_vimeo 501658124 >}}

For the coloring: I just did a simple linear combination, and corrected the gamma by hand. Here's some more multi-agent renders.

A bonus render, featuring an  interesting orange sample from testing my CMYK like color combination code...


{{< better_vimeo 515662382 >}}


Anyways, I'll most likely revisit this project in the future, as I accidentally wrote a great framework for visualizing agent based simulations. However, I'm quite burnt out from debugging, writing, and relearning Illustrator for those slick graphics earlier. Thanks again for reading and I hope you enjoyed coming with me on this little journey!

∎