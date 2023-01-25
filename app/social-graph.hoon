/+  verb, dbug, default-agent,  io=agentio,
    g=social-graph
|%
::
::  %social-graph agent state is just a graph?!
::
+$  graph  _social-graph:g
+$  card  card:agent:gall
::
::  scry paths
::
::  /nodes/[app]/[from-node]/[tag]  <-  returns (set node)
::  /edge/[from-node]/[to-node]     <-  returns (unit edge)
::  /app/[app]/[from-node]/[to-node]      <-  returns (unit (set tag))
::  /has-tag/[app]/[from-node]/[to-node]/[tag]        <-  returns ?
::  /bidirectional/[app]/[from-node]/[to-node]/[tag]  <-  returns ?
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
          %edit  (handle-edit:hc !<(edit:g vase))
        ==
      [cards this]
    ::
    ++  on-peek   handle-scry:hc
    ++  on-agent  on-agent:def
    ++  on-watch  on-watch:def
    ++  on-arvo   on-arvo:def
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
::
|_  bowl=bowl:gall
  ++  handle-edit
    |=  =edit:g
    ^-  (quip card _graph)
    ::  need this info in bowl for perms
    =/  =app:g  p.edit
    ?-    -.q.edit
        %add-tag
      `(add-tag:graph from.q.edit to.q.edit app tag.q.edit)
    ::
        %del-tag
      `(del-tag:graph from.q.edit to.q.edit app tag.q.edit)
    ::
        %nuke-tag
      `(nuke-tag:graph app tag.q.edit)
    ==
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    ?+    path
      ~|("unexpected scry into {<dap.bowl>} on path {<path>}" !!)
        [%x %nodes @ @ @ ^]
      ::  /nodes/[app]/[from-node]/[tag]
      =/  =app:g  `@tas`i.t.t.path
      =/  =node:g
        =+  `@tas`i.t.t.t.path
        ?+  -  !!
          %ship     [- (slav %p i.t.t.t.t.path)]
          %address  [- (slav %ux i.t.t.t.t.path)]
          %entity   [- `@tas`i.t.t.t.t.path]
        ==
      =/  =tag:g
        ?:  ?=([@ ~] t.t.t.t.t.path)
          `@tas`i.t.t.t.t.t.path
        t.t.t.t.t.path
      =-  ``noun+!>(`(set node:g)`-)
      (get-nodes:graph node app `tag)
    ::
        [%x %nodes @ @ @ ~]
      ::  /nodes/[app]/[from-node]
      =/  =app:g  `@tas`i.t.t.path
      =/  =node:g
        =+  `@tas`i.t.t.t.path
        ?+  -  !!
          %ship     [- (slav %p i.t.t.t.t.path)]
          %address  [- (slav %ux i.t.t.t.t.path)]
          %entity   [- `@tas`i.t.t.t.t.path]
        ==
      =-  ``noun+!>(`(set node:g)`-)
      (get-nodes:graph node app ~)
    ==
--