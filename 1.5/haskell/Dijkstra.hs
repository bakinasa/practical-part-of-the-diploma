{- |
  Dijkstra: shortest paths from source. Reads graph from file.
  Format: first line "n m source", then m lines "u v weight".
  Runs 50 times and prints avg_time_ms and checksum.
  Graph stored as Array for O(1) access to adjacency lists.
-}
module Main where

import Control.Monad (replicateM)
import Data.Array (Array, accumArray, (!), bounds)
import Data.List (foldl')
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Time.Clock.POSIX (getPOSIXTime)
import System.Environment (getArgs)
import System.IO (readFile)

type Graph = Array Int [(Int, Double)]
type Dist = Map Int Double

runs :: Int
runs = 50

parseGraph :: String -> (Graph, Int)
parseGraph contents =
  let (header : edgeLines) = lines contents
      [n, m, source] = map read (words header)
      parseEdge line = let [a, b, c] = words line in (read a :: Int, read b :: Int, read c :: Double)
      edges = map parseEdge (take m edgeLines)
      arr = accumArray (flip (:)) [] (0, n - 1) [(u, (v, w)) | (u, v, w) <- edges]
  in (arr, source)

dijkstra :: Graph -> Int -> (Dist, Double)
dijkstra adj source =
  let (_, nMax) = bounds adj
      n = nMax + 1
      inf = 1e300
      initDist = Map.fromList [(i, if i == source then 0 else inf) | i <- [0 .. n - 1]]
      initSet = Set.singleton (0.0, source)
      loop dist set =
        case Set.minView set of
          Nothing -> dist
          Just ((d, u), set') ->
            case Map.lookup u dist of
              Nothing -> loop dist set'
              Just cur ->
                if d > cur
                  then loop dist set'
                  else
                    let relax (dist2, set2) (v, w) =
                          let alt = d + w
                              old = Map.findWithDefault inf v dist2
                           in if alt < old
                                then (Map.insert v alt dist2, Set.insert (alt, v) set2)
                                else (dist2, set2)
                        (dist'', set'') = foldl' relax (dist, set') (adj ! u)
                     in loop dist'' set''
      dist = loop initDist initSet
      checksum = Map.foldl' (\a d -> a + d) 0.0 (Map.filter (< inf) dist)
  in (dist, checksum)

main :: IO ()
main = do
  args <- getArgs
  let path = case args of { [] -> "graph.txt"; (a : _) -> a }
  contents <- readFile path
  let (adj, source) = parseGraph contents
  t0 <- getPOSIXTime
  checksums <- replicateM runs (pure (snd (dijkstra adj source)))
  t1 <- getPOSIXTime
  let totalChecksum = sum checksums
  let diffSec = realToFrac (t1 - t0) :: Double
  let avgMs = diffSec * 1000 / fromIntegral runs
  putStrLn $ "avg_time_ms: " ++ show avgMs
  putStrLn $ "checksum: " ++ show totalChecksum
  putStrLn $ "runs: " ++ show runs
