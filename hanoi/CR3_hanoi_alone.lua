-- Version Lua 5.3.5
DhInit(115200,1)
Speed(100)
DhOpen(0,1)
Sync()

function hanoi(origin, pickup, lift, goal, dropoff, finish)
  
  Go(P1)
  
  Go(origin)
  DhOpen(0,1)
  Sleep( math.ceil(1  300) )
  Go(pickup)
  DhClose(0,1)
  Sleep( math.ceil(1  500) )
  Go(lift)
  Go(goal)
  Sleep( math.ceil(1  300) )
  Go(dropoff)
  DhOpen(0,1)
  Sleep( math.ceil(1  500) )
  Go(finish)
  Sleep( math.ceil(1  300) )
end

hanoi(P2, P3, P4, P5, P6, P7)
hanoi(P8, P9, P10, P11, P12, P13)
hanoi(P14, P15, P16, P17, P18, P19)
hanoi(P20, P21, P22, P23, P24, P25)
hanoi(P26, P27, P28, P29, P30, P31)
hanoi(P32, P33, P34, P35, P36, P37)
hanoi(P38, P39, P40, P41, P42, P43)
hanoi(P44, P45, P46, P47, P48, P49)
