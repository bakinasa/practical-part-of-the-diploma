inc :: Int -> Int
inc x = x + 1

main :: IO ()
main = print (inc Nothing)