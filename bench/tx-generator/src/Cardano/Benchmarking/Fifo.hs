module Cardano.Benchmarking.Fifo
where
import           Prelude

-- This is to be used single threaded behind an MVar.

data Fifo a = Fifo ![a] ![a]

emptyFifo :: Fifo a
emptyFifo = Fifo [] []

-- Warning : bad complexity when used as a persistent data structure.
toList :: Fifo a -> [a]
toList (Fifo x y) = x ++ reverse y

insert :: Fifo a -> a -> Fifo a
insert (Fifo x y) e = Fifo x $ e:y

remove :: Fifo a -> Maybe (Fifo a, a)
remove fifo = case fifo of
  Fifo [] [] -> Nothing
  Fifo (h:t) y -> Just (Fifo t y, h)
  Fifo [] y -> case reverse y of
    (h:t) -> Just (Fifo t [], h)
    [] -> error "unreachable"

removeN :: Int -> Fifo a -> Maybe (Fifo a, [a])
removeN 0 f = return (f, [])
removeN n f = do
  (a, h) <- remove f
  (r, t) <- removeN (pred n) a
  return (r, h:t)
