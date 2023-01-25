/+  verb, dbug, default-agent,  io=agentio,
    g=social-graph
|%
::
::  %social-graph agent state is just a graph?!
::
+$  graph  _social-graph:g
+$  card  card:agent:gall
::
::  !! need USERSPACE PERMS to make this right !!
::
+$  edit
  %+  pair  term  ::  the app poking us, for now
  $%  [%add-tag from=node:g to=node:g =tag:g]
      [%del-tag from=node:g to=node:g =tag:g]
      [%nuke-tag =tag:g]
  ==
::
::  scry paths
::
::  /nodes/[from-node]/[app]/[tag]  <-  returns (set node)
::  /edge/[from-node]/[to-node]     <-  returns (unit edge)
::  /app/[from-node]/[to-node]      <-  returns (unit (set tag))
::  /has-tag/[from-node]/[to-node]/[app]/[tag]        <-  returns ?
::  /bidirectional/[from-node]/[to-node]/[app]/[tag]  <-  returns ?
--
::
^-  agent:gall
%+  verb  &
%-  agent:dbug
=|  =graph
=<  |_  =bowl:gall
    +*  this  .
        hc    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init  `this(graph *_graph)
    ::
    ++  on-save  !>(graph)
    ::
    ++  on-load
      |=  old=vase
      ^-  (quip card _this)
      `this(graph !<(_graph old))
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      =^  cards  graph
        ?+  mark  (on-poke:def mark vase)
          %edit  (handle-edit:hc !<(edit vase))
        ==
      [cards this]
    ::
    ++  on-peek  handle-scry:hc
    ++  on-agent  on-agent:def
    ++  on-watch  on-watch:def
    ++  on-arvo  on-arvo:def
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
::
|_  bowl=bowl:gall
  ++  handle-edit
    |=  =edit
    ^-  (quip card _graph)
    !!
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    !!
--