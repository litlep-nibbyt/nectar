/+  verb, dbug, default-agent, io=agentio, n=nectar
|%
::
::  agent state
::
+$  state
  $:  db=_database:n
  ==
::
+$  card  card:agent:gall
--
::
^-  agent:gall
%+  verb  &
%-  agent:dbug
=|  =state
=<  |_  =bowl:gall
    +*  this  .
        hc    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init  `this(state *_state)
    ::
    ++  on-save  !>(state)
    ::
    ++  on-load
      |=  old=vase
      ^-  (quip card _this)
      `this(state !<(_state old))
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      =^  cards  state
        ?+  mark  (on-poke:def mark vase)
          %nectar-query  (handle-query:hc !<(query-poke:n vase))
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
  ++  handle-query
    |=  =query-poke:n
    ^-  (quip card _state)
    ::  modify the table with results
    `state(db +:(q:db.state query-poke))
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    ::  use this for stateless queries
    ::
    ::  TODO: how do we perform a query from a scry-path?
    ::  we need to produce a query somehow... need to either
    ::  - coax it out of path (gross)
    ::  - store the query with a poke and call by name (okay)
    ::  - ???
    ::
    !!
--