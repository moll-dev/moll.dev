---
title: "Trapped Knights"
date: 2019-02-20T22:33:58-07:00
tags: ["julia", "math", "programming"]
draft: false
---

<span class="drop-caps">A</span> few days ago, I came across a math video that perplexed me. This video, published by the great YouTube channel [Numberphile](https://www.youtube.com/channel/UCoxcjq-8xIDTYp3uz647V5A), featured Neil Sloane, the creator and maintainer of OEIS, the [On-Line Encyclopedia of Integer Sequences](https://oeis.org/).

{{< youtube RGQe8waGJ4w >}}

I love watching Numperhile's channel, they always introduce me to some math puzzle. These puzzles usually have rational explaination, packaged nicely by the video's presenter. The problem presented consisted of a few steps, tracing out the path of a knight on a special chess board, however, the results of this procession was a surprise, leaving me with more questions than answers. 

# The Setup

In the video Sloane mentions a peculiar sequence he discovered, OEIS A316667, in which, a knight moves on a chessboard consisting of an integer spiral increasing from the center point of the board `(0,0)`.

This construct is called an Ulam Spiral, which is a method to visualize the distribution of prime numbers, popularized by [Stanislaw Ulam](https://en.wikipedia.org/wiki/Stanislaw_Ulam). 


![](https://cdn.moll.dev/static/images/ulam-spiral.png)

If you're like me and haven't played chess recently, a knight has 8 possible moves, shown here.

![](https://cdn.moll.dev/static/images/knight-moves.png)

Sloane continues, mentioning that the knight must move to the position with the lowest integer that has not yet been visited. Up until now everything seems like a typical maths problem, infinite chessboard, simple rules.

After tracing out a few of the knights moves, he spills it. The knight won't continue forever, but instead get stuck, he explains: 

> After 2016th step the knight gets stuck. On the tile with the number 2084. 

When I first watched this video, I was expecting a nice mathematical explanation; maybe Pi was involved somewhere, or maybe Euler's constant could be derived from the sequence. Instead, the video concluded with a "we don't know why it stops here". Granted this sequence was only discovered last year, but it's still a very interesting result. I couldn't let this mystery end here, so I decided to implement it and do just a bit of exploration.


# The Playground

For my experimentation I decided use Julia (https://julialang.org/). Julia is an excellent language for numerical analysis, it's LLVM backed, dynamically typed, and uses the multiple dispatch paradigm. Check it out!

First things first, let's construct an Ulam spiral. Using the polynomial definition of the vertical, horizontal, and diagonal lines, I was able to derive a function which maps the space of the x,y coordinate system into the corresponding Ulam spiral integer.

I based it on 4 quadrants (NW, NE, SE, NW) and the linear combination of components from the position. Using the basic equation, each diagonal allows us to jump close to our point of interest without wasting memory or time to get there. Thanks to my high school algebra skills, this solution runs in O(1) time.

![](https://cdn.moll.dev/static/images/ulam1.png)

Here's my implementation; you'll find that Julia is pretty expressive, especially when working with equations.


```julia
"""
    Function mapping (x::Int64, y::Int64)
"""
function ulam_map(x, y)
    if x == y == 0
        return 1
    elseif -x < y <= x
        # Q1 -> NE
        n = abs(x)
        return 4n^2 - 2n + 1 - n + y
    elseif -y <= x < y
        # Q2 -> NW
        n = abs(y)
        return 4n^2 + 1 - n - x
    elseif x <= y < -x
        # Q3 -> SW
        n = abs(x)
        return 4n^2 + n + 1 - y
    elseif y < x <= -y
        # Q4 -> SE
        n = abs(y)
        return 4n^2 + 3n + 1 + x
    end
end
```



![](https://cdn.moll.dev/static/images/ulam2.png)

Cool! Now lets move onto the fun part. Trapping the Knight.



We'll first need all set of moves the knight can make, then a structure to hold the values we've visited already. Since we've got the mapping from (x,y) to n, we'll need a method to generate the next move a knight can make, given the state of the board. I'm using a dictionary to store each move as a tuple representing the delta to complete a given move. I used a set, for it's fast lookups. 

```julia
"""
    Calculate a generic next move for a generic chess piece.

    Args: 
        current_tile : Tuple{Int64,Int64}
        visited_tiles : Set(Int64)
        piece_moves : Array{Tuple{Int64,Int64},1} 
        tile_map : Function(x::Int64, y::Int64) -> Int64
        selector : Function(Array{Int64,1}) -> Int64

    Returns:
        Tuple with next move (x,y) and it's value
"""
function next_move(pos, visited)
    moves = Dict()
    for delta in knight_deltas
        move = pos .+ delta
        val = ulam_map(move...)
        if !in(val, visited)
            moves[val] = move
        end
    end

    if length(moves) > 0
        min_val = reduce((x, y) -> x ≤ y ? x : y, keys(moves))
        min_move = moves[min_val]
        return (min_move, min_val)
    else
        return ((0,0), -1)
    end
end
```

I'm no Julia expert, so this might not be the most idiomatic code. (Any fellow Julia programmers, feel free to leave some pointers!) Essentially, this code generates a possible move for a given position, excluding any moves that have already been visited, then filters them based on the smallest next value. This function returns `-1` as it's value when it's found no solutions.

Then, this code is thrown in a while-loop waiting for `next_move` to be exhausted. Here's the completed code:

```julia
using Plots
gr()

knight_moves = [(-2, -1), (-2, +1), (+2, -1), (+2, +1), (-1, -2), (-1, +2), (+1, -2), (+1, +2)]
current = (0, 0)
value = 1

# housekeeping
path = Array{Tuple{Int, Int}}(undef, 0)
ordered = Array{Int64}(undef, 0)
visited = Set(1)

push!(ordered, 1)

while value > 0
    current, value = next_move(current, visited, knight_moves, ulam_map, minimum)
    push!(path, current)
    push!(visited, value)
    push!(ordered, value)
end

# undo the last addition
pop!(path)
pop!(ordered)

println("Stopped at iteration ",length(ordered))
println("Stopped at Number ", ordered[end])

```

The path data is then plotted into a graph:

![](https://cdn.moll.dev/static/images/ulam3.png)

The `Plots` library also lets us make gifs easily. 


```julia
@gif for i=1:length(path)+30
    i = i < length(path) ? i : length(path) - 1
    plot(path[1:i], lims = (-30,30), labels = [""], aspect_ratio = :equal)
    end every 5
```

![](https://camo.githubusercontent.com/1e56e32f205e61db832f80f88c4f482a89e7af9b/687474703a2f2f692e696d6775722e636f6d2f41364b5258356c2e676966)


Look familiar?

<img src="https://camo.githubusercontent.com/7981bae293278cdad08926ef1716339287637155/68747470733a2f2f692e696d6775722e636f6d2f786e3463596c342e706e67" width="300">

Joking aside, let's try to find some structure. When I was researching the Ulam spiral for this post, I came across a plot of all the prime numbers marked on an Ulam spiral. We're told that primes are special numbers with no pattern or
closed form equation. When you take a look at the ulam prime plot:

![](https://camo.githubusercontent.com/3f877418a975baaa72a700a998f8546667e2b975/68747470733a2f2f75706c6f61642e77696b696d656469612e6f72672f77696b6970656469612f636f6d6d6f6e732f362f36392f556c616d5f312e706e67)

Your brain definitely detects some semblance of structure, however random it might be. Let's map our knight's procession with the prime numbers marked. The AKS primality test should be good enough, we only have to check around 2,000 numbers anyways.


```julia
"""
    Use AKS as a primality test
    
    Args:
        integer, possibly prime

    Return:
        boolean, if it is.
"""
function is_prime(n)
    if n == 2 || n == 3
        return true
    end
    
    if n % 2 == 0 || n % 3 ==0
        return false
    end
            
    i, w = 5, 2
            
    while i^2 <= n
        if n % i == 0
            return false
        end
        
                
        i += w
        w = 6 - w
    end
                
    return true
end
```

Then let's use it to overlay our path with prime markers. 


{{< highlight  julia "linenos=table" >}}
plot(path, lims = (-35,35), aspect_ratio = :equal, legend = :bottomright, label = ["knight's path", ""])

prime_positions = Array{Tuple{Int, Int}}(undef, 0)

for (i, pos) in enumerate(path)
    if is_prime(ordered[i])
        push!(prime_positions, pos)
    end
end

plot!(prime_positions, seriestype = :scatter, label = ["", "primes"], markersize = 3)
```


![](https://cdn.moll.dev/static/images/primespiral.PNG)

Unfortunately this doesn't reveal some magic insight about the knight's delima. Let's try blocking off the knights final position, and see how far it continues. If we get stuck again, we'll just backup and try again.

```julia

using Plots
gr()

knight_moves = [(-2, -1), (-2, +1), (+2, -1), (+2, +1), (-1, -2), (-1, +2), (+1, -2), (+1, +2)]
current = (0, 0)
value = 1

strides = Any[]
stuck_points = Tuple{Int, Int}[]
visited = Set(1)

push!(strides, Tuple{Int, Int}[(0,0)])
max_strides = 15


while length(strides) <= max_strides
    next_pos, next_value = next_move(current, visited, knight_moves, ulam_map, minimum)

    if next_value < 0
        push!(stuck_points, current)
        current = strides[end][end]
        push!(visited, value)
        push!(strides, Tuple{Int, Int}[])
    else 
        push!(visited, value)
        push!(strides[end], current)
        current = next_pos
        value = next_value
    end

end
```


We'll let the night run for an arbitrary 15 strides. 

![](https://cdn.moll.dev/static/images/knightstrides.PNG)

Looks like a giant jawbreaker candy! My first observation is that the different layers aren't consistent, some strides are very very short, while others are quite long. The blue and turquoise bands are massive! Another interesting feature of this map, the "chin" of the first path seems to get rounded off after a few strides, then becomes more pronouced a few later. And places which were generally flat on the first pass, are a bit nubby. 

I'll go a head and plot the lengths of each stride. I'm guessing they'll be generally increasing. 

![](https://cdn.moll.dev/static/images/nightstridegraph.PNG)

Looking at the data it seems like we have a loose trend. While runs 1, 5, and 12 were increasing, there are quite a bit of smaller bands under 1000 numbers. We'd expect a generally upward trend since the radius is increasing the further we get from `(0, 0)`.


# (Non) Conclusion

After setting up this experiment and taking a look at the results, It's clear I'll need brush up on my analytical math skills to continue further. For further reading, lookup "Knight's Tours" a ton of papers have been written exploring problems similar to this one. I hope this piqued your math interest and showed you a small sample of Julia along the way!

