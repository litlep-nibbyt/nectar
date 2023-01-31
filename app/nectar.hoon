/+  verb, dbug, default-agent, io=agentio, n=nectar, *mip
|%
::
::  agent state
::
+$  state
  $:  db=_database:n
      ::  keyed by app, then label
      stored-procedures=(mip term term stored-procedure:n)
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
          %nectar-query          (handle-query:hc !<(query-poke:n vase))
          %nectar-add-procedure  (handle-proc:hc !<(procedure-poke:n vase))
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
    ::  use this for stateful queries
    ::
    ?>  ?=  $?  %update        %insert
                %delete        %add-table
                %rename-table  %drop-table
                %update-rows
            ==
        -.query-poke
    `state(db +:(q:db.state query-poke))
  ::
  ++  handle-proc
    |=  pp=procedure-poke:n
    ^-  (quip card _state)
    `state(stored-procedures (~(put bi stored-procedures.state) pp))
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    ::  use this for stateless queries
    ::
    ?+    path  [~ ~]
        [%x %query @ ^]
      =/  app=@tas    i.t.t.path
      =/  label=@tas  i.t.t.t.path
      ::  apply params to axes
      =/  params=(list @)  t.t.t.t.path
      =/  proc=stored-procedure:n
        (~(got bi stored-procedures.state) app label)
      ::  inject variable params into query
      =.  q.proc
        |-
        ?~  params  q.proc
        ?~  p.proc  q.proc
        =/  val  (slav -.i.p.proc i.params)
        %=    $
            params  t.params
            p.proc  t.p.proc
            q.proc
          =-  !<(query:n [-:!>(*query:n) -])
          =<  q
          %+  slap  !>(`*`q.proc)
          :+  %cnts  ~[%&^1]
          ~[[p=~[[%& +.i.p.proc]] q=[%sand -.i.p.proc i.params]]]
        ==
      ::  perform query and return result
      ~&  >  "your query: "
      ~&  >  q.proc
      ``noun+!>(`(list row:n)`-:(q:db.state app q.proc))
    ::
        [%x %custom-query @ @ ~]
      =/  app=@tas  i.t.t.path
      =/  =query:n    ;;(query:n i.t.t.t.path)
      ::  perform query and return result
      ~&  >  "your query: "
      ~&  >  query
      ``noun+!>(`(list row:n)`-:(q:db.state app query))
    ==
--