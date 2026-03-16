{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Concurrent
import Control.Exception (evaluate)
import Control.Monad
import Data.Bits (xor, shiftR)
import Data.List (foldl')
import Data.Time.Clock.POSIX (getPOSIXTime)
import Data.Word
import System.Environment (getArgs)
import Text.Read (readMaybe)

readArg :: Read a => a -> Int -> [String] -> a
readArg def idx xs =
  case drop idx xs of
    (v:_) -> maybe def id (readMaybe v)
    [] -> def

mix64 :: Word64 -> Word64
mix64 x0 =
  let !x1 = x0 `xor` (x0 `shiftR` 33)
      !x2 = x1 * 0xff51afd7ed558ccd
      !x3 = x2 `xor` (x2 `shiftR` 33)
      !x4 = x3 * 0xc4ceb9fe1a85ec53
      !x5 = x4 `xor` (x4 `shiftR` 33)
   in x5

chunkSum :: Word64 -> Word64 -> Word64
chunkSum start end = go start 0
  where
    go !i !acc
      | i >= end = acc
      | otherwise = go (i + 1) (acc + mix64 i)

splitRanges :: Int -> Word64 -> [(Word64, Word64)]
splitRanges workers n = go 0 0
  where
    chunk = n `div` fromIntegral workers
    go i cur
      | i >= workers = []
      | i == workers - 1 = [(cur, n)]
      | otherwise =
          let next = cur + chunk
           in (cur, next) : go (i + 1) next

parSum :: Int -> Word64 -> IO Word64
parSum workers n = do
  mvars <- forM (splitRanges workers n) $ \(s, e) -> do
    mv <- newEmptyMVar
    _ <- forkIO $ do
      let !r = chunkSum s e
      putMVar mv r
    pure mv
  parts <- mapM takeMVar mvars
  pure $ foldl' (+) 0 parts

main :: IO ()
main = do
  args <- getArgs
  let mode = case args of
        (m:_) -> m
        [] -> "seq"
  let workers :: Int
      workers = readArg 1 1 args
  let n :: Word64
      n = readArg 20000000 2 args

  t0 <- getPOSIXTime

  checksum <- case mode of
    "seq" -> do
      let !r = chunkSum 0 n
      evaluate r
    "par" -> parSum workers n
    _ -> error "mode must be seq|par"

  t1 <- getPOSIXTime
  let timeMs = realToFrac (t1 - t0) * 1000 :: Double

  putStrLn "language: Haskell"
  putStrLn $ "mode: " ++ mode
  putStrLn $ "workers: " ++ show workers
  putStrLn $ "n: " ++ show n
  putStrLn $ "checksum: " ++ show checksum
  putStrLn $ "time_ms: " ++ show timeMs
