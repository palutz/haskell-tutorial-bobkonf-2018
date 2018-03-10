import Prelude

hellobobkonf = putStrLn "seems like you're all set!"

greet name = "Hello, " ++ name

absolute x = if x > 0 then x else -x 

-- pattern matching
-- order matter (always top to bottom, like f#)

boolToString :: Bool -> String
-- or using infix operator I can define like this (equivalent)
-- boolToString :: (->) Bool String
boolToString True = "True"
boolToString False = "False"

isZero 0 = True
isZero _ = False

-- infix operator
-- (+) 1 2 
-- = 3

-- recursion 
--  not taking care of the negative numbers
-- factorial 0 = 1
-- factorial n = n * factorial (n - 1)

-- recursion with guards
factorial n 
    | n > 0 = n * factorial (n -1)
    | otherwise = 1

-- define operator, (too much) easy
--
x ~= y = absolute (x - y) < 0.01
-- eg.: 
-- - 1 ~= 0.999
-- True

-- pattern matchin on operator
True  ||| _ = True
False ||| y = y

-- pattern matching on list
myHead :: [a] -> a
myHead (x:_) = x

myTail :: [a] -> [a]
myTail (_:xs) = xs

-- lambda function
-- (\x -> x * 2) 3
-- (\x y -> x + y) 4 6
-- anonymoous function with name ("!weirdo :D ) 
times3 =(\x -> x * 3)

-- recursive and pattern matching - define myLength
-- define the type.. with generic type
myLength :: [a] -> Int
-- another way to define it (to check it)
-- myLength :: [] a -> Int
myLength [] = 0
myLength (_ : xs) = 1 + myLength xs

-- f :: a -> a -> a
-- this has only 2 possible implementations cause we don't know anything about the type at this point
-- f x y = x
-- f x y = y

-- eg increment all element in a list
-- 1st implementation with recursive
incAll :: [Int] -> [Int]
incAll [] = []
incAll (x : xs) = (x + 1) : incAll xs
-- now more general it will become a map or myMap in our case, with a general function to do the increment
myMap :: (a -> b) -> [a] -> [b]
myMap f [] = []
myMap f (x : xs) = f x : myMap f xs
-- eg: 
-- > myMap (\x -> x + 1) [1..3]
-- [2,3,4]

myElem _ [] = False
myElem y (x : xs) = if y == x then True else myElem y xs

myConcat :: [a] -> [a] -> [a]
myConcat a [] = a
myConcat [] b = b
myConcat (x : xs) b = x : myConcat xs b

-- generic applier, it could be used as a calculator
f :: (a -> b -> b) -> a -> b -> b
f g x y = g x y
-- eg. : f (+) 3 2   ---> 7  or f (*) 3 2 ---> 6

sMap :: (a -> b) -> [a] -> [b]
sMap f (x : xs) = f x : myMap f xs
sMap _ [] = []

myFilter :: (a -> Bool) -> [a] -> [a]
myFilter f (x : xs) = if f(x) then x : myFilter f xs else myFilter f xs 
myFilter _ [] = []

-- function composition
-- (f . g) x = f (g x)
-- (filter (> 10) . map length) ["abc", "a", "abcdefghtrerffdsdfs"]
-- times10 x = x * 10
-- less6 x = x < 6
-- (myMap times10 . myFilter less6) [1..10]   ----> [10,20,30,40,50]
-- other composition example
-- isLong = (> 10) . length
-- application
isLong x = (> x) . length

-- DATA TYPE
-- Product Type (combination of)
data Humanoid = P String Int
-- usage: P "Stefano" 44   
-- Sum Type (one of) 
-- data Bool = True | False
data Shape = Circle Float
            | Rectangle Float Float
-- let c = Circle 10   ---> :t c  ---> c :: Shape

-- data Maybe a = Just a | Nothing
readBool :: String -> Maybe Bool
readBool "True" = Just True
readBool "False" = Just False
readBool _ = Nothing

-- data Either a b = Left a | Right b
--
myDefault :: a -> Maybe a -> a
myDefault _ (Just x) = x
myDefault y Nothing = y

shapeArea :: Shape -> Float
shapeArea (Circle r) = 3.14 * (r ^ 2)
shapeArea (Rectangle a b ) = a * b
-- let c = Circle 10
-- shapeArea c ---> 314.0

-- Recursive DATA TYPE
data Tree a = Leaf a
            | Node (Tree a) a (Tree a)

-- :t Leaf ---> Leaf :: a -> Tree a
-- :t (Leaf ".") "foo" (Leaf ",") ---> Tree [Char]
-- :t Node ---> Tree a -> a -> Tree a -> Tree a
-- type constructor are just functions, like any other functions

sumTree ::  Tree Int -> Int
sumTree Leaf a = a
sumTree (Node t1 b t2) = (sumTree t1) + a + (sumTree t2)
