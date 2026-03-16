module Main where

relax :: Double -> Double -> Double -> Double
relax old du w =
  let alt = du + w
   in if alt < old then alt else old

step :: Double -> Double -> Double -> Double
step old du w = relax old du w

main :: IO ()
main = print (step 10.0 3.0 4.0)
