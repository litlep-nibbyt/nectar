::
::  solid-state-subscription "lake"
::
/-  sg=social-graph
|%
++  name  %subgraph
+$  rock  nodeset:sg
+$  wave
  $%  [%new-edge from=node:sg to=node:sg]
      [%gone-edge from=node:sg to=node:sg]
      [%gone-tag ~]
  ==
++  wash
  |=  [=rock =wave]
  ?-  -.wave
    %new-edge   (~(put ju rock) [from to]:wave)
    %gone-edge  (~(del ju rock) [from to]:wave)
    %gone-tag   *_rock
  ==
--
