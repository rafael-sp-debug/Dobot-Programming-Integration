-- Version: Lua 5.3.5
DhInit(115200,1)
Speed(100)
DhOpen(0,1)
Sync()

function pick_and_place(origin, pickup, lift, goal, dropoff, finish)
  
  Go(P1)
  
  Go(origin)
  DhOpen(0,1)
  Sleep( math.ceil(1 * 1000) )
  Go(pickup)
  DhClose(0,1)
  Sleep( math.ceil(1 * 1000) )
  Go(lift)
  Go(goal)
  Sleep( math.ceil(1 * 500) )
  Go(dropoff)
  DhOpen(0,1)
  Sleep( math.ceil(1 * 1000) )
  Go(finish)
  Sleep( math.ceil(1 * 1000) )
end

pick_and_place(P2, P3, P4, P5, P6, P7)
pick_and_place(P8, P9, P10, P11, P12, P13)
pick_and_place(P14, P15, P16, P17, P18, P19)
