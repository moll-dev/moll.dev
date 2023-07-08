---
title: "Julia used Multiple Dispatch! It's Super Effective!"
date: 2021-07-19T15:44:36-07:00
tags: ["julia", "type-systems", "multiple-dispatch"]
draft: false
---

![Pokelogo](https://cdn.moll.dev/static/images/pokejulia/pokelogo-01.png)

These days, I find myself evangelizing for [Julia](https://julialang.org/) quite a bit. It's a good language, especially for scientific computing, but I believe its focus on performance also makes it a good general language as well. At some level, programmers who know multiple languages have an abstract understanding of the constructs used within various languages: I/O, looping, branching, etc. And there's an understanding that if you needed to write some computation, given enough time, you could probably write it in any language I gave you. 

That being said, there are a number of "nice to have" features that greatly improve the programming experience. For instance: generics, polymorphic structures, dynamic typing, multiprocessing, libraries, etc. These aren't necessarily deal breakers, but they can greatly increase the ease at which code is written, reducing unnecessary complexity, and improving collaboration. 

Often times, while extolling the virtues of Julia, I'll casually mention one of those "nice to have" features: [multiple dispatch](https://docs.julialang.org/en/v1/manual/methods/). Usually met with a "what's that?" and the inevitable "well when would you use _that?_". Then I'll scramble to string together an explanation, trying not to dive too deeply into abstract PL concepts. I never had a _great_ example, until now.

# Pokémon

Pokémon is a cultural powerhouse, not only the 4th best selling video game franchise, it has a trading card game, TV shows, movies, and manga. Today, I'll be focusing on the video game, in which Pokémon Trainers battle with creatures known as "Pokémon". These Pokémon have a type and a set of attacks which trainers can use in battle. 

An important mechanic of a Pokémon battle is the [type advantage](https://pokemondb.net/type) in which the strength of the attack can be made more or less effective depending on the type of the attack and the type of the pokemon defending. For sake of brevity, I'll be implementing the first 9 Pokémon types: `Normal`, `Fire`, `Water`, `Electric`, `Grass`, `Ice`, `Fighting`, `Poison` and `Ground`. And an `eff` function telling us how effective the attack was. 

_Image from https://pokemondb.net/type_
![PokeType chart](https://cdn.moll.dev/static/images/pokejulia/typechart.png)

Pokémon types are a good choice because they have a complex, yet concrete relationship with one another. For example: `Water` attacking `Fire` is concretely defined as being "super effective". It's also easy enough to understand, even for people who haven't played the game. And it's fun!

# PokéTypes

Starting off, we'll need a "container" type, otherwise known as "supertype". In Julia, we can only subtype `abstract` types, concrete types cannot be subtyped further. As we'll see inheriting behavior is much more important than inheriting structure. Let's define it!

```Julia
abstract type PokéType end
```

This will create that "container" for the rest of our types, as a form of organization, which will come in handy down the line. We can visualize this abstract type like this:

![fig1.1](https://cdn.moll.dev/static/images/pokejulia/fig1.1-01.png)


Look at all that empty space! So much opportunity. We'll use the dashed line to represent its `abstract` nature, we won't (and can't) be implementing this type directly. For that we'll need another type. We'll use the subtype operator `<:` to logically nest our new type "inside" `PokéType`. You may be familiar the "boxes and arrows" type hierarchy, I'll be using a more general Venn diagram approach here.

Let's define the `Normal` type
```Julia
struct Normal <: PokéType end
```

![fig1.2](https://cdn.moll.dev/static/images/pokejulia/fig1.2-01.png)

The `<:` operator can also act as a boolean statement, checking whether a given type is a subtype of another.

```julia
@assert Normal <: PokéType
@assert typeof(Normal()) <: PokéType
```

So far so good  ? Let's define our first interaction. Since we only have one concrete type `Normal` we can only implement `Normal` to `Normal` attacks. We'll write a function `eff` that takes two arguments `atk` and `def` and returns a value related to the effectiveness. We'll use the `::` operator to specify that we only want this function to run when we're dealing with two `Normal` types.

```julia
const NO_EFFECT          = 0.0
const NOT_VERY_EFFECTIVE = 0.5
const NORMAL_EFFECTIVE   = 1.0
const SUPER_EFFECTIVE    = 2.0

function eff(atk::Normal, def::Normal) 
    return NORMAL_EFFECTIVE
end
```

![fig1.3](https://cdn.moll.dev/static/images/pokejulia/fig1.3-01.png)

Above, the arrow represents the direction _from_ the attack _to_ the defender. Going forward, for any of these "self-to-self" interactions, we'll just use an arrow looping back.

We can then test this out with a basic example:
```Julia
function attack!(atk, def)
    effectiveness = eff(atk, def)
    println("A Pokémon used a $(typeof(atk)) attack")
    println("against a $(typeof(def)) Pokémon")
    println("it was $(eff_string(effectiveness))")
end

attacker = Normal()
defender = Normal()
attack!(attacker, defender)
```

```Julia
> A Pokémon used a Normal attack
> against a Normal Pokémon
> it was normally effective.
```

Seems... normal to me. Now to implement the remaining types. We're just going to do 9 types, as these cover all the cases we would expect for a `PokéType`. Same as before, using the `<:` operator.


```julia
struct Fire     <: PokéType end
struct Water    <: PokéType end
struct Electric <: PokéType end
struct Grass    <: PokéType end
struct Ice      <: PokéType end
struct Fighting <: PokéType end
struct Poison   <: PokéType end
struct Ground   <: PokéType end
```
![fig1.5](https://cdn.moll.dev/static/images/pokejulia/fig1.5-01.png)

If we have `N` different types, we'll need to define N^2 interactions. Potentially 81 different functions. However, if you notice, there are a couple of patterns in the type chart above. First, there's a lot of empty or normal interactions, and second, nearly every self-to-self interaction is "not very effective". 

As you might expect, if we try to use any of these types we'll get an error. Specifically a `MethodError` informing us that no function with these matching types exists.
```julia
attacker = Fire()
defender = Water()
attack!(attacker, defender)
```
```julia
> MethodError: no method matching eff(::Fire, ::Water)
```

Let's go ahead and define a _catch-em-all_ function. I'll using the shorthand assignment method to define this function. Here, `T1` and `T2` are just a stand-ins for whatever types might be passed to this function. We then use the `where` keyword to ensure that this function only gets called if _both_ types are a subtype of `PokéType`. Notice how we use different parametric type variables, this allows us to match this function if both types are the same or different.
```julia
eff(atk::T1, def::T2) where {T1 <: PokéType, T2 <: PokéType} = NORMAL_EFFECTIVE
```
{{< sticky id="1" content="Some parents thought that Pokémon was encouraging 'satanic worship'. I'm beginning to see why..." >}}

![fig1.6](https://cdn.moll.dev/static/images/pokejulia/fig1.6-01.png)

```julia
attacker = Fire()
defender = Water()
attack!(attacker, defender)
```
```julia
> A Pokémon used a Fire attack
> against a Water Pokémon
> it was normally effective.
```

Now we're getting somewhere!

Using parametric types, give us a _generic_ way to specify arguments, while still bounding their type. 
Effectively, Julia's dispatcher is checking the following dynamically:

```julia
Normal <: PokéType && Normal <: PokéType
```

and

```julia
Normal <: PokéType && Fire <: PokéType 
```


Now all types have an interaction, albeit an incorrect one for multiple cases. For example, self-to-self attacks are incorrect, they should be "not very effective" for most types, with a few exceptions.

```julia
attacker = Fire()
defender = Fire()
attack!(attacker, defender)

```
```julia
> A Pokémon used a Fire attack
> against a Fire Pokémon
> it was normally effective.
```

We'll need to properly define this self-to-self interaction. We can also cover the corner cases of `Fighting` and `Ground` where they don't take the effectiveness hit.
```julia
eff(atk::T, def::T) where {T <: PokéType} = NOT_VERY_EFFECTIVE
eff(atk::Fighting, def::Fighting)         = NORMAL_EFFECTIVE
eff(atk::Ground,   def::Ground)           = NORMAL_EFFECTIVE
```

![fig1.6a](https://cdn.moll.dev/static/images/pokejulia/fig1.6a-01.png)

Moving forward, we'll use yellow arrows / grey lines to represent "normal effectiveness", blue arrows to represent "not very effective", and red arrows to represent "super effectiveness".

Let's define the "super effective" attacks:
```julia
eff(atk::Fire,     def::Grass)    = SUPER_EFFECTIVE
eff(atk::Fire,     def::Ice)      = SUPER_EFFECTIVE
eff(atk::Water,    def::Fire)     = SUPER_EFFECTIVE
eff(atk::Water,    def::Ground)   = SUPER_EFFECTIVE
eff(atk::Electric, def::Water)    = SUPER_EFFECTIVE
eff(atk::Grass,    def::Water)    = SUPER_EFFECTIVE
eff(atk::Grass,    def::Ground)   = SUPER_EFFECTIVE
eff(atk::Ice,      def::Grass)    = SUPER_EFFECTIVE
eff(atk::Ice,      def::Ground)   = SUPER_EFFECTIVE
eff(atk::Fighting, def::Normal)   = SUPER_EFFECTIVE
eff(atk::Fighting, def::Ice)      = SUPER_EFFECTIVE
eff(atk::Poison,   def::Grass)    = SUPER_EFFECTIVE
eff(atk::Ground,   def::Fire)     = SUPER_EFFECTIVE
eff(atk::Ground,   def::Electric) = SUPER_EFFECTIVE
eff(atk::Ground,   def::Poison)   = SUPER_EFFECTIVE
```
![fig1.6b](https://cdn.moll.dev/static/images/pokejulia/fig1.6b-01.png)

And then the "not very effective" attacks:
```julia
eff(atk::Fire,     def::Water)  = NOT_VERY_EFFECTIVE
eff(atk::Water,    def::Grass)  = NOT_VERY_EFFECTIVE
eff(atk::Electric, def::Grass)  = NOT_VERY_EFFECTIVE
eff(atk::Grass,    def::Fire)   = NOT_VERY_EFFECTIVE
eff(atk::Grass,    def::Poison) = NOT_VERY_EFFECTIVE
eff(atk::Ice,      def::Fire)   = NOT_VERY_EFFECTIVE
eff(atk::Ice,      def::Water)  = NOT_VERY_EFFECTIVE
eff(atk::Fighting, def::Poison) = NOT_VERY_EFFECTIVE
eff(atk::Poison,   def::Ground) = NOT_VERY_EFFECTIVE
eff(atk::Ground,   def::Grass)  = NOT_VERY_EFFECTIVE
```
![fig1.6d](https://cdn.moll.dev/static/images/pokejulia/fig1.6c-01.png)

Aaaaand one last case, just because `Electric` types cannot attack `Ground`.

```julia
eff(atk::Electric, def::Ground) = NO_EFFECT
```

![fig1.6e](https://cdn.moll.dev/static/images/pokejulia/fig1.6e-01.png)

By my count, we only had to implement 30 out of the 81 total possible interactions! That's an amazing amount of code reuse!
Now to address the elephant in the room. Multiple Dispatch.

# Multiple Dispatch is _not_ method overloading

I'll admit, multiple dispatch is a super abstract concept, one that you really only appreciate when you need it. For instance, if you ever find yourself doing a bunch of `isinstance` in your Python code and it just _feels_ bad, you're running into the limitations of static binding and single dispatch (i.e. polymorphism via a single type, myClass.method1, etc.). 

Method overloading involves resolution of types at compile time and _statically_ generating bound methods to operate on during run time. For example, in Java.


```Java
abstract class PokemonType {}
class Normal extends PokemonType {}

class Main {  
  public static Double eff(Normal atk, Normal def) { return 1.0; }
  public static Double eff(PokemonType atk, PokemonType def) { return -1.0; }

  public static void main(String args[]) { 
    Normal n1 = new Normal();
    Normal n2 = new Normal();

    Pokemon pokemon1 = new Pokemon(n1);

    System.out.println(eff(n1, n2));
  }
}
```

This will correctly print out `1.0`
```julia
> javac -d . Main.java; java Main
> 1.0
```

Up until this point, this code will work for most languages with overloading, as these types can be statically calcuated at compile time, and methods can be statically assigned to any calls involving them. Until we try and encapsulate! In order to _actually_ use our fancy types, we'll need to encapsulate this information inside something more useful. We'll define a class called `Pokemon` which just holds a `PokeType`. The instant we instantiate a `Pokemon` object, something is lost. Our specific type `Normal` becomes just a generic `PokeType`, meaning we won't correctly dispatch!

```Java
abstract class PokeType {}
class Normal extends PokeType {}

class Pokemon {
  public PokeType type;

  public Pokemon(PokeType givenType) {
    type = givenType;
  }
}

class Main {  
  public static Double eff(Normal atk, Normal def) { return 1.0; }
  public static Double eff(PokeType atk, PokeType def) { return -1.0; }

  public static void main(String args[]) { 
    Normal n1 = new Normal();
    Normal n2 = new Normal();

    Pokemon pokemon1 = new Pokemon(n1);

    System.out.println(eff(pokemon1.type, pokemon1.type));
  }
}
```

As you can see, our program prints out the incorrect value, meaning the less specific function was bound.
```julia
> javac -d . Main.java; java Main
> -1.0
```

If we wanted to make this work in Java, we would have to use reflection to manually check types during run time, effectively stuffing all of our type interactions into `public static Double eff(PokeType atk, PokeType def)`. 
This might seem reasonable, however, Java's virtual machine is optimized for static types, optimizing any call paths _before_ runtime. 

Compared to Julia, we see it works as expected. `p1.type` is correctly resolved and dispatched!
```Julia
struct Pokemon 
    type::PokéType
end
    
p1 = Pokemon(Normal())
    
eff(p1.type, p1.type)
```
```julia
> 1.0
```

Julia is able to stay performant while also allowing us this flexibility due to its optimization of runtime types within its JIT design. Admittedly, I still need to dive into Julia's internals to give a better answer here, potentially for another blog post.

Anyways, let's take a look at the last advantage of Multiple Dispatch in Julia, composition.

# Composition is King

Implementing such a system of interaction in another language isn't impossible, but extremely heavy handed without Multiple Dispatch. For example, if we wanted to brute force this, we could just implement a single function, and just check the type of each argument, checking NxN cases exhaustively. 

For example, [check this horrendous gist](https://gist.github.com/QuantumFractal/222658d42be2b4c5bc1a9ba8c9f8d419) I wrote.

If someone wanted to implement a new type, and define more interactions, they would have to _completely_ rewrite this function. Not to mention the possibility of completely breaking this fragile brute force method.
Good luck trying to resolve merge conflicts! With Julia, this operation is "super effective", we only need to import the existing types!

``` julia
# Assuming we've import PokéType and it's subtypes already

# Define a new type
struct Flying <: PokéType end

# Implement all instances where Flying is on defence
eff(atk::Electric, def::Flying) = SUPER_EFFECTIVE
eff(atk::Grass,    def::Flying) = NOT_VERY_EFFECTIVE
eff(atk::Ice,      def::Flying) = SUPER_EFFECTIVE
eff(atk::Fighting, def::Flying) = NOT_VERY_EFFECTIVE
eff(atk::Ground,   def::Flying) = NO_EFFECT

# Implement all instances where Flying is attacking
eff(atk::Flying, def::Electric) = NOT_VERY_EFFECTIVE
eff(atk::Flying, def::Grass)    = SUPER_EFFECTIVE
eff(atk::Flying, def::Fighting) = SUPER_EFFECTIVE

# Implement the self-to-self case, apparently birds can't attack one another :/
eff(atk::Flying, def::Flying) = NO_EFFECT
```

We've added a completely new type, and all of its interactions, completely separate from any other implementations! And in the future, if we miss any new types, we'll fall back to the generic case!

Wrapping up, I've shown that Julia's dynamic type system and multiple dispatch are powerful tools that enable extremely expressive code and trivial extensibility. Hopefully I've convinced you to at least check out Julia, if not try and use it in your next side project. Thanks again for reading!

∎