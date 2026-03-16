module Main where

import System.CPUTime (getCPUTime)

iters :: Int
iters = 20000000

step :: Double -> Double -> Double -> Double
step old du w =
  let alt = du + w
   in if alt < old then alt else old

loop :: Int -> Double -> Double -> Double -> Double -> Double
loop 0 acc _ _ _ = acc
loop k acc old du w =
  let old' = step old du w
      du' = if du + 0.000001 > 1000.0 then 1.0 else du + 0.000001
      w' = if w + 0.000002 > 1000.0 then 0.5 else w + 0.000002
   in loop (k - 1) (acc + old') old' du' w'

main :: IO ()
main = do
  t0 <- getCPUTime  -- picoseconds
  let acc = loop iters 0.0 1000000.0 1.0 0.5
  t1 <- getCPUTime
  let ms = fromIntegral (t1 - t0) / 1e6  -- picoseconds to milliseconds
  putStrLn $ "time_ms: " ++ show ms
  putStrLn $ "checksum: " ++ show acc
  putStrLn $ "iters: " ++ show iters
