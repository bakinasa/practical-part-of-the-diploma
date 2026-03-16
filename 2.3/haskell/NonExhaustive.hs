data Color = Red | Green | Blue

toCode :: Color -> Int
toCode Red = 1
toCode Green = 2

main :: IO ()
main = print (toCode Blue)