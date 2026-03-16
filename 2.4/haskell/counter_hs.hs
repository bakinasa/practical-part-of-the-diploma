{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Concurrent
import Control.Monad
import Data.Bits ((.&.))
import Data.IORef
import Data.Int
import Data.Time.Clock.POSIX (getPOSIXTime)
import System.Environment (getArgs)
import Text.Read (readMaybe)

readArg :: Read a => a -> Int -> [String] -> a
readArg def idx xs =
  case drop idx xs of
    (v:_) -> maybe def id (readMaybe v)
    [] -> def

incRace :: IORef Int64 -> Int64 -> IO ()
incRace ref iters = go 0
  where
    go !i
      | i >= iters = pure ()
      | otherwise = do
          x <- readIORef ref
          when (i .&. 1023 == 0) yield
          writeIORef ref $! (x + 1)
          go (i + 1)

incAtomic :: IORef Int64 -> Int64 -> IO ()
incAtomic ref iters = go 0
  where
    go !i
      | i >= iters = pure ()
      | otherwise = do
          atomicModifyIORef' ref (\x -> let !y = x + 1 in (y, ()))
          go (i + 1)

incMVar :: MVar Int64 -> Int64 -> IO ()
incMVar mv iters = go 0
  where
    go !i
      | i >= iters = pure ()
      | otherwise = do
          x <- takeMVar mv
          let !y = x + 1
          putMVar mv y
          go (i + 1)

runWorkers :: Int -> IO () -> IO ()
runWorkers workers action = do
  doneVars <- replicateM workers newEmptyMVar
  forM_ doneVars $ \d ->
    forkIO (action >> putMVar d ())
  mapM_ takeMVar doneVars

main :: IO ()
main = do
  args <- getArgs
  let variant = case args of
        (v:_) -> v
        [] -> "race"
  let workers :: Int
      workers = readArg 4 1 args
  let iters :: Int64
      iters = readArg 200000 2 args

  t0 <- getPOSIXTime

  observed <- case variant of
    "race" -> do
      ref <- newIORef 0
      runWorkers workers (incRace ref iters)
      readIORef ref
    "atomic" -> do
      ref <- newIORef 0
      runWorkers workers (incAtomic ref iters)
      readIORef ref
    "mvar" -> do
      mv <- newMVar 0
      runWorkers workers (incMVar mv iters)
      readMVar mv
    _ -> error "variant must be race|atomic|mvar"

  t1 <- getPOSIXTime

  let expected = fromIntegral workers * iters
      timeMs = realToFrac (t1 - t0) * 1000 :: Double

  putStrLn "language: Haskell"
  putStrLn $ "variant: " ++ variant
  putStrLn $ "workers: " ++ show workers
  putStrLn $ "iterations_per_worker: " ++ show iters
  putStrLn $ "expected: " ++ show expected
  putStrLn $ "observed: " ++ show observed
  putStrLn $ "ok: " ++ show (if expected == observed then 1 else 0 :: Int)
  putStrLn $ "time_ms: " ++ show timeMs
