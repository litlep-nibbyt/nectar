/+  verb, dbug, default-agent, io=agentio, n=nectar
|%
::
::  agent state
::
+$  state
  $:  db=_database:n
  ==
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
          %nectar-query  (handle-query:hc !<(query:n vase))
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
    |=  =query:n
    ^-  (quip card _state)
    ::  queries from poke are assumed to be stateful,
    ::  modify the table with results
    !!
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    !!
--