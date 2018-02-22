# Introductory Haskell, bobkonf'18

These are the course materials for http://bobkonf.de/2018/heinzel.html

Based on last year's tutorial by Matthias Fischmann,
which in turn was based on earlier tutorials with Andres Löh, Alexander Ulrich.

If you have any questions or technical problems,
you can open an issue and I will try my best to help you!

## Setting things up

You will need the Glasgow Haskell Compiler (GHC).
I recommend installing it through the build tool Stack,
which can manage GHC and package installations for you.
Please follow the
[installation instructions on their website](https://docs.haskellstack.org/en/stable/install_and_upgrade/)!

Then, check out this repository using `git`
and install GHC through Stack.

```
git clone https://github.com/mheinzel/haskell-tutorial-bobkonf-2018.git
cd haskell-haskell-tutorial-bobkonf-2018
stack setup
```

This can take a few minutes.
You should be able to start the interactive interpreter GHCi now (again, through Stack).

```
stack ghci
...
(some more info)
...

> 1 + 2
3
```

Of course, you can install GHC any way you want to.
As long as you can start GHCi, you're fine.
If you are not a fan of the command line,
there is the [Haskell Platform](https://www.haskell.org/platform/),
which comes with WinGHCi, a graphical version of GHCi.


## The workflow

We want to explore Haskell by evaluating expressions in GHCi,
but sometimes it's useful to define a few things in a text file.
To try this, open the provided file Main.hs in GHCi.

```
stack ghci Main.hs
```

And use one of the things defined there.

```
*Main> hellobobkonf
seems like you're all set!
```

To reload the file after changing something, type `:r` into GHCi.

## Basic Syntax

Values of several types:

~~~haskell
> 42
> 2.3
> "foo"  -- a string
> 'x'    -- a single character
> True
> False
> (42, "foo")  -- a tuple
~~~

~~~haskell
-- There are the usual operators with expected precedence
> 2 + 3 * 4 - 1
> 5 / 2
> "foobar" == "foo" ++ "bar"
-- Function application is syntactically lightweight.
> length "haskell"
-- but you need parentheses to show that `sqrt 5` is one argument,
-- not `sqrt` and `5`.
> round (sqrt 5)
~~~

More forms of expressions:

~~~haskell
-- let-bindings
> let x = 5 in x + 42

-- conditionals
> if x == 5 then [42] else []
~~~

You can define things in the interactive shell to use it later:

~~~haskell
> name = "matthias"
> "hey, " ++ name
~~~

These are *definitions*, declarations that always hold true,
not mutable variables.
Statements such as `x = x + 1` do not make sense in this setting.

Feel free to play around a bit!


## Functions

We can also define functions. Again, whitespace separates the arguments.

I recommend defining them in a file so you will have them around later.
Also, multi-line definitions in GHCi require some thought (hint: `:{` and `:}`).
Don't forget to reload the file with `:r`!

~~~haskell
-- Functions with one parameter
greet you = "hey, " ++ you
absolute x = if x >= 0 then x else -x

-- Functions with two parameters
mul x y = x * y
greetWith greeting you = greeting ++ ", " ++ you
~~~

You can also *pattern-match* on specific values.
The cases will be tried top to bottom.

~~~haskell
boolToSlang True = "yep"
boolToSlang False = "nope"

isZero 0 = True
isZero _ = False  -- underscore for arguments you don't care about
~~~

This is useful for defining recursive functions with a base case.

~~~haskell
factorial 0 = 1
factorial n = n * factorial (n - 1)
~~~

Let's see how that would evaluate:

~~~
factorial 4                       ==
4 * factorial 3                   ==
4 * (3 * factorial 2)             ==
4 * (3 * (2 * factorial 1))       ==
4 * (3 * (2 * (1 * factorial 0))) ==
4 * (3 * (2 * (1 * 1)))           ==
4 * (3 * (2 * 1))                 ==
4 * (3 * 2)                       ==
4 * 6                             ==
24
~~~

You can also define your own operators, but don't go too far!

~~~haskell
-- approximate equality
x ~=~ y = abs (x - y) < 1

-- my own `or`
True  ||| _ = True
False ||| r = r
~~~

Side note: An infix operator can be used as a regular function:

~~~
> (|||) True False
~~~

Additionally, any function with two arguments can be used as an infix
operator by enclosing it in backticks.

~~~
> 5 `elem` [1, 2, 3, 5]
~~~

Functions are first-class values - regular values that you
can pass around like any other.
You can also create them on the fly.

~~~haskell
> (\word -> word ++ reverse word) "test"

-- equivalent to `add x y = x + y`
> add = (\x y -> x + y)
> add 2 3
~~~

These are called *anonymous functions* or *lambda expressions*.


## Inductive list definition, list construction examples

Lists are an important data structure in Haskell (as in most other
functional languages).

Lists are defined *inductively*. You might know the schema from
various Lisp or ML dialects.

~~~
-- The empty list
> []

-- Construct a new list from a value (head) and a list (tail): cons
> 2 : []

-- Constructing lists with more elements
> 1 : (2 : [])

-- Without parentheses
> 1 : 2 : []

-- Syntactic sugar for list construction
> [1, 2, 3]
> 42 : [1, 2, 3]
> [42, 19] ++ [1, 2, 3]
~~~

Syntax `[e_1, ..., e_n]` is transformed into an equivalent expression
using the cons `(:)` operator.


## Functions on lists

### list length

*Deconstruct* the list according to its inductive definition by
 *pattern matching*. A list is either empty or a cons combination of a
 value and some other list. Treat the cases separately!

~~~haskell
-- The empty list has length 0
myLength []        = 0
-- A list is one longer than its tail
myLength (hd : tl) = 1 + myLength tl
~~~

~~~
myLength [1..3]           ==
myLength (1 : 2 : 3 : []) ==
1 + myLength (2 : 3 : []) ==
1 + 1 + myLength (3 : []) ==
1 + 1 + 1 + myLength ([]) ==
1 + 1 + 1 + 0           ==
3
~~~

* Two equations, two cases for the underlying data type: case-wise
  function definition. Very common pattern for function definitions
* A *recursive* call deals with the tail of the list (if necessary)
* **boolean or: short-cut evaluation**
* In Haskell, all bindings are mutually recursive by default

### list membership

~~~haskell
-- Any value is certainly not an element of the empty list
myElem _ [] = False

-- Check wether the head value equals 'x' or if 'x' occurs
-- in the tail of the list.
myElem x (y : ys) = x == y || myElem x ys
~~~

~~~
> myElem 5 [6, 9, 42]
> myElem 9 [6, 9, 42]
~~~


## Lazy Evaluation

Short-cut behaviour of boolean operators is not a special hack in Haskell.

Lazy evaluation: function arguments are evaluated only when they are
actually required. Usually, *required* means that they are matched on.

~~~
-- A special value that raises an exception when it is evaluated
> undefined

-- Only need to evaluate the first argument to True to give the result
> True || undefined

-- Need to evaluate the second argument.
> False || undefined
~~~

Lazy evaluation is neat:

~~~
> let allIntegers = [1..]
-- Show evaluation status of binding. Thunks are marked with an underscore
> :print allIntegers
> :t take
> take 10 allIntegers
> :print allIntegers
> :t sum
> sum (take 10 allIntegers)
> sum allIntegers
~~~

We can work with non-terminating computations:

~~~haskell
ones = 1 : twos

twos = 2 : ones
~~~


## Type Inference

Haskell is a strong and statically typed language. The compiler checks
if every expression is type-correct.

*But*: We have not seen any type signatures so far. How is this
 consistent with static typing?

*Answer*: The compiler can infer the type of an expression from the
 types of its sub-expressions. *Type inference*

Example:

~~~haskell
not True  = False
not False = True
~~~

From the code, we can conclude that:

* It's a function (it has an argument)
* It takes a truth value
* It produces a truth value

~~~haskell
not :: Bool -> Bool
~~~

The compiler checks wether we have given a correct type for the
function.

We can also ask the compiler for the type of some expression or
function:

~~~
> :t not
> :t not True
~~~

What is the type of the "or" function?

~~~
> True || False
~~~

It takes two bools and produces a bool:

~~~haskell
(||) :: Bool -> Bool -> Bool

-- Actually: A function that is applied to a bool and gives us another function.
(||) :: Bool -> (Bool -> Bool)
~~~

Let's return to our `myElem` function. We can give its type as follows:

~~~haskell
myElem :: Int -> [Int] -> Bool

-- But actually, it's this type:
myElem :: Int -> ([Int] -> Bool)
~~~

What is the type of `myElem 5`?

Functions with more than one parameter can be *partially
applied*. Partial application specializes (or fixes) a function on
some parameters.

~~~haskell
containsFive :: [Int] -> Bool
containsFive = myElem 5
~~~

~~~
> containsFive [1, 2, 3]
> containsFive [1..10]
~~~


## (Parametric) Polymorphism

Let's define a function that appends two lists of integers.

~~~haskell
myConcat :: [Int] -> [Int] -> [Int]

-- Case 1: first argument is the empty list
myConcat [] ys     = ys

-- Case 2: non-empty first argument.
myConcat (x:xs) ys = x : myConcat xs ys
~~~

Do we use the fact that we append lists of *integers*
specifically? Wouldn't the code for appending lists of strings look
exactly the same (except in the type signature)?

==> Remove type signature

~~~
myConcat ["foo", "bar"] ["baz"]
~~~

What, then, is the type of `myConcat`? Let's ask the compiler. For any
program, Haskell infers not only *some* type, but *the most general
type*.

~~~
:t myConcat
myConcat :: [a] -> [a] -> [a]
~~~

Read this as: For *any element type* `a`, the function takes two lists
of `a` and produces a new list of `a`. Crucially though, both
arguments must have *the same* element type.

`a` is a type variable which can be *instantiated* to any type.

*Parametric polymorphism*: A function behaves the same, regardless of
the type. Parametric polymorphism is a powerful way to write abstract
and generic code.

The more general the type of a function, the fewer things it can do.
What can a function `f :: Int -> Int` do with its argument `x`?

- `2 * x`
- `(-1) ^ x`
- `x + 1`
- `x + 2`
- ...

What can a function `f :: a -> a` do with its arguments?

- return it

That's it.


## Higher Order Functions

Another polymorphic function

~~~haskell
map :: (a -> b) -> [a] -> [b]
map f (x:xs) = f x : map f xs
map _ []     = []
~~~

Note also that this is a higher-order function.  It takes another
function as an argument.

~~~
> map (elem 5) [[1..10], [2..4], []]
> map (+ 1) [1, 2, 3, 4, 5]
~~~


## Data types

Haskell supports a powerful mechanism to define new data types:
*algebraic data types* or *sums of products*.

Simple example:

~~~haskell
data Maybe a = Just a | Nothing
~~~

~~~
> Just 3
> Nothing
> [Just 3, Just False]
> [Just 3, Nothing, Just 5]
~~~

~~~haskell
data Either a b = Left a | Right b
~~~

~~~
> [Left 3, Right False]
~~~

(Both `Maybe` and `Either` are `Monad`s.  Enough said.  :-)

Let's define a data type for binary trees with node labels of *some
type*. The type gets a *type parameter*.

~~~haskell
data Tree a = Leaf
            | Node (Tree a) a (Tree a)
~~~

We have two constructors. A `Leaf` is a tree, as well as a `Node`,
applied to three parameters. Note that the type is recursive: A tree
contains two child trees (if it is a `Node`).

This is an easy example of a generic data structure.

~~~
-- The 'Leaf' constructor is a valid tree for /any/ element type.
> :t Leaf
> :t Node Leaf "foo" Leaf
~~~

Side note: What is the type of `Node`?

~~~
> :t Node
~~~

Data constructors are just functions and can be treated like any other
function.

Functions over data types usually follow the structure of inductively
defined types by pattern matching and recursion (just as in the case
of lists).

~~~haskell
sumTree :: Tree Int -> Int
sumTree Leaf           = 0
sumTree (Node t1 x t2) = sumTree t1 + x + sumTree t2

t :: Tree Int
t = Node
       (Node Leaf 3 Leaf)
       91
       (Node
           (Node Leaf 16 (Node Leaf 21 Leaf))
           24
           Leaf)

sumTree t
~~~

We can interpret binary trees as *search trees*. Write a function that
checks wether a value is a member of a given search tree.

~~~haskell
elemTree :: Ord a => a -> Tree a -> Bool
elemTree _ Leaf = False
elemTree a (Node t1 x t2) =
  if a == x then True          else
  if a < x  then elemTree a t1 else
                 elemTree a t2
~~~


## Purity and Effects

*purity* or *referential transparency*:

> You can replace any two expressions by each other that evaluate to
  the same value.

> The value of a piece of code is everything that matters.

> *No effects* (widget manipulation, disk access, random data
   generation, ...)

No, wait:

> *Effects are explicit* in the types!

~~~
generateRandomNumber :: Int -> IO Int
readString           :: IO String
~~~

`IO a` is an action that may have some effects and yields an `a`.

`generateRandomNumber` always retursn the same *action* on the same
input `Int`, so referential transparency still holds!

Main entry point of every program:

```haskell
main :: IO ()
main = putStrLn "hello, world"
```


## Holes

In Haskell, the expressive type system allows to specify interesting
properties of programs. But furthermore, we can also let us be *guided
by types* during development.

~~~haskell
mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe = _
~~~

An expression that begins with an underscore is called a *hole*. The
Haskell compiler gives us information about the type of the expression
that we should fill the hole with.

Things to learn here:

- break up your problem (pattern matching), and put the pieces back
  together (make the types fit).
- `Maybe` and `[]` are related (how?).
- even with types you need to keep your brain running while coding.  :)


# Tools, Infrastructure, Further Reading


## Library search and distribution

- http://hayoo.fh-wedel.de/, https://www.stackage.org/
    - fuzzy-search for stuff by name or type signature
    - Stackage only covers the packages provided in its snapshots,
      but seems to provide better results than Hayoo

- https://hackage.haskell.org/
    - package repository

- http://www.stackage.org/
    - provides snapshots of the most popular packages
      that are guaranteed to build together


## Package management

- cabal:
    - haskell package manager
    - powerful version dependency constraint solver
- stack:
    - alternative to cabal, younger and more pragmatic
    - uses stackage snapshots instead of finding compatible package versions using a solver
    - manages compiler versions and dependencies without polluting the global namespace
- both based on the Cabal library.


## IDEs

https://wiki.haskell.org/IDEs

https://github.com/rainbyte/haskell-ide-chart


## Books

- [Learn You a Haskell For Great Good](http://learnyouahaskell.com/)
  - free online book
  - not very in-depth
  - almost no exercises
- [Programming in Haskell](http://www.cs.nott.ac.uk/~pszgmh/pih.html)
  - good book with online material
- [Haskell Programming from First Principles](http://www.cs.nott.ac.uk/~pszgmh/pih.html)
  - probably most up-to-date resource
  - currently only provides digital copies, but there will be a printed version soon
  - very extensive
  - lots of exercises


## Learn more

- http://stackoverflow.com/questions/tagged/haskell
- http://www.reddit.com/r/haskell
- https://github.com/sdiehl/wiwinwlh
- https://ocharles.org.uk/blog
- http://haskellcast.com/
- irc: freenode \#haskell-beginners, \#haskell
- Slack: https://fpchat-invite.herokuapp.com/
- https://github.com/NicoleRauch/FunctionalProgrammingForBeginners


## Consulting / Training

- http://well-typed.com/blog
