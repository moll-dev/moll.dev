---
title: "Reaction Diffusion modelling with Julia and CUDA"
date: 2020-02-27T15:07:37-08:00
tags: ["julia", "GPU"]
draft: false
---


![big-chonker](https://cdn.moll.dev/static/projects/reaction-diff/big-chonker.JPG)



<span class="drop-caps">A</span> few months ago I happened upon a Wikipedia article about [Turing Patterns](https://en.wikipedia.org/wiki/Turing_pattern). These are complex patterns which arise from a uniform and homogenous initial state. Turing's paper _The Chemical Basis of Morphogenesis_ suggested an explanation based on chemical reagents in a cycle of generation and consumption. The giant puffer fish above displays some of the patterns Turing describes.

I was fascinated by the idea that a complex pattern could arise from a simple set of equations. Emergent behavior and patterns have always been an interest of mine. I then found a fairly popular set of equations to generate these patterns. The model mainly consists of a `NxM` matrix with each cell containing a variable scalar `A` and `B` representing the reactants and products respectively. The model also captures a few constant scalars `Da`, `Db`, `f` and `k` representing the rate of diffusion of the reactants, a "feed" rate of reactant `A` and the "kill" rate of reactant `B`, respectively.


$$\frac{\partial{A}}{\partial{t}} = D_{a} \nabla^{2} A - A B^{2} + f (1 - A)$$

$$\frac{\partial{B}}{\partial{t}} = D_{b} \nabla^{2} B + A B^{2} - B (k + f)$$

The overall idea is this: `A` is fed into the system at rate limited inversely by the concentration of `A`. `A` is consumed to produce `B` depending on the concentration of `AB^2`. `B` is then killed off at a rate limited directly by the concentration of `B`. The products and reactants are also diffused through the system by `∇`.
The `∇` operator is a function to compute the diffusion of each substance via a 2D Laplace convolution kernel shown below:

$$\nabla kernel = \begin{bmatrix} 0.05 & 0.2 & 0.05 \\\\\\ 0.2 & -1 & 0.2 \\\\\\ 0.05 & 0.2 & 0.05 \end{bmatrix}$$

This kernel will slowly disperse our chemicals (both `A` and `B`) evenly without adding or removing matter since:

$$\sum{\nabla kernel} = 0$$

When you put this all together, you can begin to see fantastic patterns emerge! Like magic!


# Interesting Examples

Alright, I'll cut to the chase: scroll on for some interesting animations.
{{< sticky id="3" content="Keep reading on if these piqued your interest and you want to know more about how I generated these patterns." >}}

By varying the `feed` and `kill` rates, we can generate all sorts of cool patterns. Some of which exhibit different behaviors; there are bi-stable patterns which oscillate, patterns which look like Voronoi triangulation, and even patterns which mimic [cellular automata](https://plato.stanford.edu/entries/cellular-automata/)! Computer scientist [Robert Munafo](http://mrob.com/pub/index.html) has done some extensive research on these patterns. He compiled all the [patterns](http://mrob.com/pub/comp/xmorphia/pearson-classes.html) he found on his website.

<div class="cf pa2">
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Negatons</div>
        <div class="f5 mt-1 iosevka">(F=0.0460, k=0.0594)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/negatons_2.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Bubbles</div>
        <div class="f5 mt-1 iosevka">(F=0.0620, k=0.0609)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/bubbles_1.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Fledgling Spirals</div>
        <div class="f5 mt-1 iosevka">(F=0.0620, k=0.0609)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/spirals_1.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Gamma</div>
        <div class="f5 mt-1 iosevka">(F=0.022, k=0.051)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/gamma_1.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Theta</div>
        <div class="f5 mt-1 iosevka">(F=0.038, k=0.061)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/theta_1.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Mu</div>
        <div class="f5 mt-1 iosevka">(F=0.058, k=0.065)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/mu_2.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Xi</div>
        <div class="f5 mt-1 iosevka">(F=0.014, k=0.047)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/xi_2.mp4" type="video/mp4">
            </source>
          </video>
    </div>
    <div class="fl w-100 w-50-ns pa2 tc db">
        <div class="custom2020 tc f3 pb-1">Sigma</div>
        <div class="f5 mt-1 iosevka">(F=0.110, k=0.0523)</div>
          <video class="player" controls loop preload="auto"  data-setup="{}">
            <source src="https://molldevblob.blob.core.windows.net/content/media/gs-rd/sigma_1.mp4" type="video/mp4">
            </source>
          </video>
    </div>
</div>

A quick note: these animations are plotted non-linearly with respect to time. I've tweaked the time between snapshots for artistic effect. All animations were solved over 200 epochs, each with varying number of steps (on average 300) per epoch. Some higher-order structures take a longer time step to see any meaningful movement and need more steps between frames. For performance reasons, these are all generated with my GPU based solver. All examples rendered on an Intel i9-7900X, 32GB of RAM and an NVIDIA RTX 2080ti.

# Creating a Proof of Concept on CPU

My first approach was to implement everything on CPU using Julia. First things first, let's take a crack at computing the `∇²` diffusion function over a `NxM` matrix. At most we're looking at an `O(n x m)` function which loops through each dimension, calculating the next diffusion factor with a constant neighborhood via direct convolution. I looked into doing this by Fourier transform via [FFTW](https://github.com/JuliaMath/FFTW.jl) but ran into some weird Julia 1.2.0 compatibility issues. It's also a bit harder to understand the math while it might be slightly faster. I used Julia's `view` function to select a neighborhood of cells without additional memory copies and multiplied that against the convolution kernel and summed it.

```julia
function ∇²(A::Array{Float32,2})
    """ Compute the Laplace Transform via Direct Convolution """
    k_ℒ = Float32[[0.05 0.2 0.05]
                   [0.2  -1 0.2 ]
                   [0.05 0.2 0.05]]
    A_prime = fill(0.0f0, size(A))
    
    Threads.@threads for y = 1:size(A, 2)
        Threads.@threads for x = 1:size(A,1)
            # Bound A
            by_A = max(1, y - 1) : min(size(A,2), y + 1)
            bx_A = max(1, x - 1) : min(size(A,1), x + 1)

            # Bound Laplace Kernel
            by_ℒ = 1 + δ(y, 1) : size(k_ℒ, 2) - δ(y, size(A, 2))
            bx_ℒ = 1 + δ(x, 1) : size(k_ℒ, 1) - δ(x, size(A, 1))

            # Calculate subarray views
            v_A = view(A, by_A, bx_A)
            v_ℒ = view(k_ℒ, by_ℒ, bx_ℒ)

            # Compute transform
            A_prime[y, x] = sum(v_ℒ .* v_A)
        end
    end
    
    return A_prime
end
```

{{< sticky id="3" content="Spoilers: I added the `Threads.@threads` line after the fact. My first implementation was naïve and slow. Isn't threading easy in Julia?" >}}

If we just pass the diffusion operation to our image, we'll get something somewhat similar to a Gaussian blur. 


{{%
    video mp4="https://molldevblob.blob.core.windows.net/content/media/gs-rd/diffusion_ex1.mp4"
%}}



 I wrote a separate version of the `∇²` function which takes a reference to the output array to avoid any extra allocations. Originally, when running a microbenchmark on `∇²` I kept running out of memory... 
 
Next we'll create some functions to compute the next frames for `A` and `B`. Following 
along with the equation, we compute diffusion step and multiply it by the diffusion factor, then, compute 
the amount of `A` consumed per cell, and then compute the creation of `A` given by the feed rate. Note: We're also pre-allocating the next matrix to avoid additional memory allocations.

```julia
function A_prime!(A′::Array{Float32,2}, A::Array{Float32,2},
                  B::Array{Float32,2}, DA::Float32,
                  f::Float32, t::Float32)
    ∇²A = fill(0.0f0, size(A))
    ∇²!(∇²A, A)

    Threads.@threads for y = 1:size(A, 2)
        for x = 1:size(A,1)
            diffusion = DA * ∇²A[x,y] 
            consumption = A[x,y] * B[x,y]^2
            creation = f * (1 - A[x,y])
            A′[x,y] = A[x,y] + (diffusion - consumption + creation) * t
        end
    end
end
```


{{< sticky id="3" content="Typically when a function is a mutator, the 'julian' thing to do is add a `!` at the end of the function name." >}}

For `B` we'll do something very similar, key difference being we're using the production term to generate new material and a modified destruction term to control the growth rate of our product.

```julia
function B_prime!(B′::Array{Float32,2}, A::Array{Float32,2}, 
                  B::Array{Float32,2}, DB::Float32, f::Float32, 
                  k::Float32, t::Float32)
    ∇²B = fill(0.0f0, size(B))
    ∇²!(∇²B, B)
    
    Threads.@threads for y = 1:size(B, 2)
        for x = 1:size(B,1)
            diffusion = DB * ∇²B[x,y]
            production = A[x,y] * B[x,y]^2
            destruction = (k + f) * B[x,y]
            B′[x,y] = B[x,y] + (diffusion + production - destruction) * t
        end
    end
end;
```

With both functions put together, let's create a struct to hold all the data our model needs. We'll also create a constructor to allocate memory and initialize our matrices.

```julia
mutable struct GrayScottReactionDiff_CPU <: Function
    t::Float32    # time delta
    
    world_size::Tuple{Int64, Int64}
    
    feed::Float32    # feed rate
    kill::Float32    # kill rate
   
    A::Array{Float32,2}    # Chemical "A"
    B::Array{Float32,2}    # Chemical "B"
    
    A′::Array{Float32,2}    # Temporary Buffers
    B′::Array{Float32,2}
    
    elapsed_steps::Int64
    
    D_a::Float32    # Diffusion Rate of A
    D_b::Float32    # Diffusion Rate of B
    
    function GrayScottReactionDiff_CPU(world_size::Tuple{Int64, Int64}, 
                                       D_a::Float32, D_b::Float32, 
                                       feed::Float32, kill::Float32)
        self = new()

        self.elapsed_steps = 0
        self.world_size = world_size
        self.A = fill(1.0f0, world_size)
        self.B = fill(0.0f0, world_size)
        
        self.A′ = fill(1.0f0, world_size)
        self.B′ = fill(0.0f0, world_size)
        
        self.D_a = D_a
        self.D_b = D_b
        self.feed = feed
        self.kill = kill
        
        self.t = 1.0f0

        return self
    end
end
```

{{< sticky id="3" content="If you wondered why we're using Float32 instead of Float64; it _can_ be faster but it makes comparison with our GPU model much nicer." >}}

Next we'll put it all together and implement our `solve!` function which will compute a given number of steps.

```julia
function solve!(model::GrayScottReactionDiff_CPU, steps::Int64)
    for step = 1:steps
        model.elapsed_steps += 1
        A_prime!(model.A′, model.A, model.B,
                 model.D_a, model.feed, model.t)
        model.A = model.A′
        
        B_prime!(model.B′, model.A, model.B, 
                 model.D_b, model.feed, model.kill, model.t)
        model.B = model.B′
    end
end;
```

And with that, we've got a fully working solver!


# GPU Acceleration or: How I Learned to Stop Worrying and Love the LLVM

I originally finished the CPU solver a few months ago, as I was able to generate some basic patterns at low resolution. For resolutions less than 256, it was fast enough to check correctness, but left me unable to iterate quickly, even with 20 hyperthreaded cores running all out on my desktop. This really took the wind out of my sails, exploration is flat out impossible with long enough waiting times between runs. In the samples section, I mentioned that I ran every model with 200 epochs and on average 300 steps per epoch. For the `sigma` pattern it took 100,000 steps overall. Using the table below: for the 1024x1024 resolution, 100k steps would have taken over 20 HOURS on my i9-7900X @ 4.10 GHz running on all cores. With GPU the same could be rendered in under 5 minutes.

```julia
[Time per 100 steps on CPU]
Benchmarking world size 32   ... 30.266 ms  (184692 allocations: 14.85 MiB)
Benchmarking world size 64   ... 107.448 ms (543992 allocations: 43.14 MiB)
Benchmarking world size 128  ... 421.888 ms (1915904 allocations: 152.28 MiB)
Benchmarking world size 256  ... 1.616 s    (7847202 allocations: 625.12 MiB)
Benchmarking world size 512  ... 8.597 s    (31498539 allocations: 2.46 GiB)
Benchmarking world size 1024 ... 74.169 s   (161392606 allocations: 12.69 GiB)
```

Hitting a wall this big after some serious CPU optimization work is very bad for morale. However, I knew this is an embarrassingly parallel problem; I knew I would have to write some sort of GPU accelerated code to speed things up. Even though I have experience with C++ CUDA kernels, I wanted to avoid the pain of debugging, especially if it's just for a side project. However, Julia has the perfect answer.

Since Julia is an LLVM language, before execution, the source code gets converted to an Intermediate Representation or IR which goes through a series of optimization stages or "passes". The IR then can be converted into machine code for a variety of platforms. LLVM is essentially a programming language Rosetta Stone. We can take a peek into the IR with the `@code_llvm` and machine code with `@code_native` macros.


```julia
@code_llvm 1 + 2
;  @ int.jl:53 within `+'
; Function Attrs: uwtable
define i64 @"julia_+_11106"(i64, i64) #0 {
top:
  %2 = add i64 %1, %0
  ret i64 %2
}
```

```julia
@code_native 1 + 2
; ┌ @ int.jl:53 within `+'
	pushq	%rbp
	movq	%rsp, %rbp
	leaq	(%rcx,%rdx), %rax
	popq	%rbp
	retq
	nopw	(%rax,%rax)
; └
```

The IR is designed to be simple and represent a common subset of operations a computer might perform, i.e adding, loading, shifting, branching. The native code is what actually runs on the target processor. I'm admittedly a bit out of my depth when it comes to all the LLVM internals, so I'll leave things here and any interested readers shoud check out [this introduction to LLVM](http://www.aosabook.org/en/llvm.html).

Circling back to GPUs, they run code compiled via NVCC, a specialized compiler for the Simultaneous Multi-Threading (SMTs) cores on a GPU. My RTX 2080ti has around 4,352 CUDA cores all able to process information in parallel. A kernel will typically handle a very small chunk of data to be combined later.

This all sounds great, but how do we access this power via Julia?

Fortunately, NVIDIA was kind enough to write an [LLVM backend](https://developer.nvidia.com/cuda-llvm-compiler) to facilitate easy language integration. This means we can write Julia code and have it automatically compile to CUDA Kernels. Enter [CuArrays](https://github.com/JuliaGPU/CuArrays.jl) and [CUDANative](https://github.com/JuliaGPU/CUDAnative.jl), libraries which allow for memory allocation on the GPU seamlessly, and launching of GPU kernels with a simple macro. I'll let one of the main authors behind these libraries, [Simon Danisch explain how to use Julia with GPU](https://nextjournal.com/sdanisch/julia-gpu-programming)

For our purposes, we'll need to make a few changes to our model.

```julia
mutable struct GrayScottReactionDiff_GPU <: Function
    t::Float32    # time delta
    
    feed::Float32    # feed rate
    kill::Float32    # kill rate
    
    world_size::Tuple{Int64, Int64} # World size
    
    elapsed_steps::Int64     # Bookkeeping
    elapsed_epochs::Int64
    max_epochs::Int64
   
    A::CuArray{Float32,2}    # Chemical "A"
    B::CuArray{Float32,2}    # Chemical "B"
    
    checkpoints::CuArray{Float32,3}
    
    D_a::Float32    # Diffusion Rate of A
    D_b::Float32    # Diffusion Rate of B
    
    function GrayScottReactionDiff_GPU(world_size::Tuple{Int64, Int64}, max_epochs::Int64, D_a::Float32, D_b::Float32, feed::Float32, kill::Float32)
        self = new()

        self.elapsed_steps = 0
        self.elapsed_epochs = 1
        self.max_epochs = max_epochs
        
        self.world_size = world_size
        w, h = world_size
        self.A = CuArrays.fill(1.0f0, world_size)
        self.B = CuArrays.fill(0.0f0, w, h)
        self.checkpoints = CuArrays.fill(0.0f0, w, h, max_epochs)
        
        self.D_a = D_a
        self.D_b = D_b
        self.feed = feed
        self.kill = kill
        
        self.t = 1.0f0

        return self
    end
end
```

Main differences here being we're typing our matrices as `CuArray` and using `CuArrays.fill(1.0f0, world_size)` to initialize an array on our GPU device. Notice we're also creating a 3-dimensional array to checkpoint individual frames for creating animations later. 

We'll start with the solver method, where we use the `@cuda` macro to launch a GPU task. `CuArrays.@sync` is used to ensure the solver waits until all threads / blocks are finished, before continuing to the next frame.

```julia
function solve!(model::GrayScottReactionDiff_GPU, steps::Int64)
    L = 8
    w, h = model.world_size

    # BIG ASSUMPTION: We're playing with square worlds only.
    block_size = Int(floor(w/L))
    
    for step = 1:steps
        model.elapsed_steps += 1
        # A, B, D_a, D_b, f, k, t, w, h, e
        CuArrays.@sync @cuda blocks=(block_size, block_size) threads=(L,L) solver_kernel(model.A, model.B, model.D_a, model.D_b, model.feed, model.kill, model.t, w, h, model.elapsed_epochs)
    end
end;
```

Next, we'll go onto the actual kernel which gets launched on the GPU.

```julia
function solver_kernel(A, B, D_a, D_b, f, k, t, w, h, e)
    # Get block index.
    i = (blockIdx().x-UInt32(1)) * blockDim().x + threadIdx().x
    j = (blockIdx().y-UInt32(1)) * blockDim().y + threadIdx().y
    
    # Model field aliases.
    ∇²A = ∇²_kernel(A, i, j, w, h)
    ∇²B = ∇²_kernel(B, i, j, w, h)
    
    A[i,j] = A[i,j] + (D_a * ∇²A - A[i,j] * B[i,j] ^ 2 + f * (1 - A[i,j])) * t
    B[i,j] = B[i,j] + (D_b * ∇²B + A[i,j] * B[i,j] ^ 2 - (k + f) * B[i,j]) * t
    
    nothing
end
```

Notice anything? It's just a regular Julia function. It uses some functions from `CUDAnative` like `blockIdx` and `threadIdx`, which should be familiar to any CUDA programmer, but everything else is standard Julia. The biggest difference is that this kernel gets launched for every cell in the matrix. We give the kernel a pointer to the `A` and `B` frames and our model parameters, then we generate which cell (i, j) our kernel is supposed to be working on, compute the local diffusion gradient, and it's business as usual computing the next values for `A` and `B`.

The function `∇²_kernel` may look a bit weird. This is because I unrolled the loop to sum the neighborhood and used some math to prevent out-of-bounds memory accesses. 

{{< sticky id="3" content="I later learned that Julia's `@inbounds` macro work with CUDA to prevent bad memory access. Whoops!" >}}

I'm also avoiding branching which is costly on GPU. This is because modern processors use hardware to pre-fetch results in case of a branch-prediction-miss, CUDA isn't as tolerant to diverging kernels and you'll see a global performance hit. I'm fairly certain the LLVM IR would catch this, but consider this a bit of premature optimization. 

```julia
function ∇²_kernel(A, i, j, ui, uj)
    nw, n, ne = 0.05, 0.2, 0.05
    w,  c, e  =  0.2,-1.0, 0.2
    sw, s, se = 0.05, 0.2, 0.05
    
    # Here we're using clamp and some algebra to replicate the 
    # Kronecker Delta function which is essentially 
    # i == j ? 1 : 0 but avoids potentially costly branching.

    top , bottom = j - 1, uj - j
    left, right  = i - 1, ui - i

    nw *= clamp(top * left, 0, 1)
    n  *= clamp(top, 0, 1)
    ne *= clamp(top * right, 0, 1)
    w  *= clamp(left, 0, 1)
    e  *= clamp(right, 0, 1)
    sw *= clamp(bottom * left, 0, 1)
    s  *= clamp(bottom, 0, 1)
    se *= clamp(bottom * right, 0, 1)
    
    # Clamp local neighborhood
    x1, x2 = max(i-1, 1), min(i+1, ui)
    y1, y2 = max(j-1, 1), min(j+1, uj)

    # Sum over local neighborhood
    lapl  = A[x1, y1] * nw + A[i, y1] * n + A[x2, y1] * ne
    lapl += A[x1, j]  * w  + A[i,j]   * c + A[x2, j]  * e
    lapl += A[x1, y2] * sw + A[i, y2] * s + A[x2, y2] * se
    
    return Float32(lapl)
end
```

Putting it all together, and running a benchmark we see that GPU is a significantly faster almost 6 orders of magnitude faster! 

```julia
[Time per 100 steps on CPU]
Benchmarking world size 32   ... 30.266 ms  (184692 allocations: 14.85 MiB)
Benchmarking world size 64   ... 107.448 ms (543992 allocations: 43.14 MiB)
Benchmarking world size 128  ... 421.888 ms (1915904 allocations: 152.28 MiB)
Benchmarking world size 256  ... 1.616 s    (7847202 allocations: 625.12 MiB)
Benchmarking world size 512  ... 8.597 s    (31498539 allocations: 2.46 GiB)
Benchmarking world size 1024 ... 74.169 s   (161392606 allocations: 12.69 GiB)

[Time per 100 steps with CUDA + GPU]
Benchmarking world size 32   ... 6.901 ms   (3300 allocations: 101.56 KiB)
Benchmarking world size 64   ... 7.279 ms   (3300 allocations: 101.56 KiB)
Benchmarking world size 128  ... 10.888 ms  (3300 allocations: 101.56 KiB)
Benchmarking world size 256  ... 25.906 ms  (3300 allocations: 101.56 KiB)
Benchmarking world size 512  ... 75.254 ms  (3700 allocations: 107.81 KiB)
Benchmarking world size 1024 ... 223.983 ms (3700 allocations: 107.81 KiB)
```