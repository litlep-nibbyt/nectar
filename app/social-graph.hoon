/-  subgraph
/+  verb, dbug, default-agent, io=agentio,
    g=social-graph, *mip, *sss
|%
::
::  %social-graph agent state
::
+$  versioned-state
  $%  [%0 *]
      state-1
  ==
+$  state-1
  $:  %1
      graph=social-graph:g
      perms=(map app:g permission-level:g)
      tracking=(map [app:g tag:g] ship)
  ==
+$  card  card:agent:gall
::
::  scry paths
::
::  /controller/[app]/[tag]  <-  returns @p of who we source a tag from
::  /nodes/[app]/[from-node]/[tag]  <-  returns (set node)
::  /nodeset/[app]/[tag]            <-  returns the nodeset at app+tag
::  /edge/[from-node]/[to-node]     <-  returns (set tag)
::  /app-tags/[app]                 <-  returns (set tag)
::  /has-tag/[app]/[from-node]/[to-node]/[tag]        <-  returns loobean
::  /bidirectional/[app]/[from-node]/[to-node]/[tag]  <-  returns loobean
--
::
^-  agent:gall
%+  verb  &
%-  agent:dbug
::  SSS declarations
=/  subgraph-sub  (mk-subs subgraph ,[%track @ @ ~])
=/  subgraph-pub  (mk-pubs subgraph ,[%track @ @ ~])
::
=|  state=state-1
=<
|_  =bowl:gall
+*  this  .
    hc    ~(. +> bowl)
    def   ~(. (default-agent this %|) bowl)
    da-sub
      =/  da  (da subgraph ,[%track @ @ ~])
      ~(. da subgraph-sub bowl -:!>(*result:da) -:!>(*from:da))
    du-pub
      =/  du  (du subgraph ,[%track @ @ ~])
      ~(. du subgraph-pub bowl -:!>(*result:du))
::
++  on-init  `this(state *state-1)
::
++  on-save  !>([state subgraph-sub subgraph-pub])
::
++  on-load
  |=  =vase
  ^-  (quip card _this)
  =/  old  !<([=versioned-state =_subgraph-sub =_subgraph-pub] vase)
  :-  ~
  %=  this
    state  ?+(-.versioned-state.old *state-1 %1 versioned-state.old)
    subgraph-sub  subgraph-sub.old
    subgraph-pub  subgraph-pub.old
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %social-graph-edit
    ?>  =(our src):bowl
    =/  =edit:g  !<(edit:g vase)
    ::  !! need this info in bowl for perms !!
    =/  =app:g  p.edit
    ?:  ?=(%set-perms -.q.edit)
      `this(perms.state (~(put by perms.state) app level.q.edit))
    =/  =tag:g
      ?-  -.q.edit
        ?(%add-tag %del-tag)  tag.q.edit
        %nuke-tag             tag.q.edit
      ==
    ::  tag cannot be empty
    ?:  ?=(~ tag)
      ~|("social-graph: tag cannot be empty!" !!)
    =^  wave  graph.state
      ?-  -.q.edit
          %add-tag
        :-  [%new-edge tag from.q.edit to.q.edit]
        (~(add-tag sg:g graph.state) from.q.edit to.q.edit app tag)
          %del-tag
        :-  [%gone-edge tag from.q.edit to.q.edit]
        (~(del-tag sg:g graph.state) from.q.edit to.q.edit app tag)
          %nuke-tag
        :-  [%gone-tag tag ~]
        (~(nuke-tag sg:g graph.state) app tag)
      ==
    ::  hand out update to subscribers on this app and (top-level) tag
    =^  cards  subgraph-pub
      (give:du-pub [%track app i.tag ~] wave)
    [cards this]
  ::
      %social-graph-track
    ?>  =(our src):bowl
    =,  !<(track:g vase)
    ::  don't track yourself..
    ?>  !=(our.bowl source)
    ?:  ?=(~ tag)
      ~|("social-graph: tracked tag cannot be empty!" !!)
    :_  this(tracking.state (~(put by tracking.state) [app -.tag^~] source))
    (surf:da-sub source %social-graph [%track app -.tag ~])^~
  ::
      %sss-on-rock
    =/  msg  !<(from:da-sub (fled vase))
    ?-    -.msg
        [%track @ @ ~]
      =/  =app:g  `@tas`-.+.-.msg
      =/  =tag:g  `path`+.+.-.msg
      =.  graph.state
        ?~  wave.msg
          ::  if no wave, use rock in msg as setpoint
          =/  l=(list [=tag:g =nodeset:g])  ~(tap by rock.msg)
          |-
          ?~  l  graph.state
          =-  $(l t.l, graph.state -)
          %-  ~(replace-nodeset sg:g graph.state)
          [nodeset.i.l app tag.i.l]
        ::  integrate wave into our local graph
        ?-    -.u.wave.msg
            %new-edge
          %-  ~(add-tag sg:g graph.state)
          [from.u.wave.msg to.u.wave.msg app tag.u.wave.msg]
            %gone-edge
          %-  ~(del-tag sg:g graph.state)
          [from.u.wave.msg to.u.wave.msg app tag.u.wave.msg]
            %gone-tag
          (~(nuke-tag sg:g graph.state) app tag.u.wave.msg)
        ==
      `this
    ==
  ::
      %sss-to-pub
    =/  msg  !<(into:du-pub (fled vase))
    ?-    -.msg
        [%track @ @ ~]
      =/  =app:g  `@tas`-.+.-.msg
      =/  =tag:g  `path`+.+.-.msg
      =/  perm  (~(gut by perms.state) app %private)
      ::  only allow permitted subscribers
      ?.  ?|  =(%public perm)
              ?&  =(%only-tagged perm)
                  ::  src.bowl must appear in nodeset under top-level tag
                  =/  =nodeset:g  (~(get-nodeset sg:g graph.state) app tag)
                  ?:  (~(has by nodeset) [%ship src.bowl])  %.y
                  %-  ~(any by nodeset)
                  |=(n=(set node:g) (~(has in n) [%ship src.bowl]))
          ==  ==
        `this
      ::  separately from permissions, ignore subscribers
      ::  to tags that we ourselves are trackers for. this
      ::  is a choice that can be edited if desired, but if so,
      ::  note that rocks/waves we receive do not trigger us to
      ::  send out ones ourselves.
      ?:  !=(our.bowl (~(gut by tracking.state) [app tag] our.bowl))
        `this
      =^  cards  subgraph-pub
        (apply:du-pub msg)
      [cards this]
    ==
  ::
      %sss-subgraph
    =^  cards  subgraph-sub
      (apply:da-sub !<(into:da-sub (fled vase)))
    [cards this]
  ==
::
++  on-peek   handle-scry:hc
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?>  ?=(%poke-ack -.sign)
  ?~  p.sign  `this
  %-  (slog u.p.sign)
  ?+    wire   `this
      [~ %sss %on-rock @ @ @ %track @ @ ~]
    =.  subgraph-sub  (chit:da-sub |3:wire sign)
    `this
  ==
::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ?+  wire  `this
    [~ %sss %behn @ @ @ %track @ @ ~]  [(behn:da-sub |3:wire) this]
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::  start helper core
|_  =bowl:gall
++  handle-scry
  ::  /controller/[app]/[tag]  <-  returns @p of who we source a tag from
  ::  /nodes/[app]/[from-node]/[tag]  <-  returns (set node)
  ::  /nodeset/[app]/[tag]            <-  returns the nodeset at app+tag
  ::  /tags/[from-node]/[to-node]     <-  returns (set tag)
  ::  /app-tags/[app]                 <-  returns (set tag)
  ::  /has-tag/[app]/[from-node]/[to-node]/[tag]        <-  returns loobean
  ::  /bidirectional/[app]/[from-node]/[to-node]/[tag]  <-  returns loobean
  |=  =path
  ^-  (unit (unit cage))
  ?:  |(?=(~ path) !=(%x i.path) ?=(~ t.path))  !!
  =/  path  t.path
  ?:  ?=([%is-installed ~] path)
    ``json+!>(`json`[%b &])
  :^  ~  ~  %social-graph-result
  !>  ^-  graph-result:g
  ?+    path
    ~|("unexpected scry into {<dap.bowl>} on path {<path>}" !!)
  ::
  ::  /controller/[app]/[tag]
  ::  returns the ship who controls a given app+tag for us
  ::
      [%controller @ ^]
    =/  =app:g  `@tas`i.t.path
    =/  =tag:g  t.t.path
    controller+?~(who=(~(get by tracking.state) [app tag]) our.bowl u.who)
  ::
  ::  /nodeset/[app]/[tag]
  ::  returns the full nodeset (jug node node) in given app+tag
  ::
      [%nodeset @ ^]
    =/  =app:g  `@tas`i.t.path
    =/  =tag:g  t.t.path
    nodeset+(~(get-nodeset sg:g graph.state) app tag)
  ::
  ::  /nodes/[app]/[from-node]/[tag]
  ::  returns a set of all nodes connected to given node in given app+tag
  ::
      ?([%nodes @ ?(%ship %address) @ ^] [%nodes @ %entity @ @ ^])
    =/  =app:g  `@tas`i.t.path
    =/  =node:g
      =+  i.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.path)]
        %entity   [- [`@tas`i `@t`i.t]:t.t.t.path]
      ==
    =/  =tag:g  t.t.t.t.path
    nodes+(~(get-nodes sg:g graph.state) node app `tag)
  ::
  ::  /nodes/[app]/[from-node]
  ::  returns a set of all nodes connected to given node in given app
  ::
      ?([%nodes @ ?(%ship %address) @ ~] [%nodes @ %entity @ @ ~])
    =/  =app:g  `@tas`i.t.path
    =/  =node:g
      =+  i.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.path)]
        %entity   [- [`@tas`i `@t`i.t]:t.t.path]
      ==
    nodes+(~(get-nodes sg:g graph.state) node app ~)
  ::
  ::  /edge/[app]/[from-node]/[to-node]
  ::  returns a set of all tags on edge between two nodes, in given app
  ::
      $%  [%tags @ ?(%ship %address) @ ?(%ship %address) @ ~]
          [%tags @ ?(%ship %address) @ %entity @ @ ~]
      ==
    =/  =app:g  `@tas`i.t.path
    =/  n1=node:g
      =+  i.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.path)]
      ==
    =/  n2=node:g
      =+  i.t.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.t.path)]
        %entity   [%entity `@tas`i `@t`i.t]:t.t.t.t.path
      ==
    =-  tags+?~(- ~ (~(get ju u.-) app))
    (~(get-edge sg:g graph.state) n1 n2)
  ::
      $%  [%tags @ %entity @ @ ?(%ship %address) @ ~]
          [%tags @ %entity @ @ %entity @ @ ~]
      ==
    =/  =app:g  `@tas`i.t.path
    =/  n1=node:g
      [i `@tas`i.t `@t`i.t.t]:t.t.path
    =/  n2=node:g
      =+  i.t.t.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.t.t.path)]
        %entity   [%entity `@tas`i `@t`i.t]:t.t.t.t.t.path
      ==
    =-  tags+?~(- ~ (~(get ju u.-) app))
    (~(get-edge sg:g graph.state) n1 n2)
  ::
  ::  /app-tags/[app]
  ::  returns set of all tags stored by given app
  ::
      [%app-tags @ ~]
    =/  =app:g  `@tas`i.t.path
    app-tags+(~(get-app-tags sg:g graph.state) app)
  ::
  ::  /has-tag/[app]/[from-node]/[to-node]/[tag]
  ::  returns true if tag exists on given edge, false otherwise
  ::
      $%  [%has-tag @ ?(%ship %address) @ ?(%ship %address) @ ^]
          [%has-tag @ ?(%ship %address) @ %entity @ @ ^]
      ==
    =/  =app:g  `@tas`i.t.path
    =/  n1=node:g
      =+  i.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.path)]
      ==
    =/  n2=node:g
      =+  i.t.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.t.path)]
        %entity   [%entity `@tas`i `@t`i.t]:t.t.t.t.path
      ==
    =/  =tag:g
      ?-  i.t.t.t.t.path
        ?(%ship %address)  t.t.t.t.t.t.path
        %entity            t.t.t.t.t.t.t.path
      ==
    (~(has-tag sg:g graph.state) n1 n2 app tag)
  ::
      $%  [%has-tag @ %entity @ @ ?(%ship %address) @ ^]
          [%has-tag @ %entity @ @ %entity @ @ ^]
      ==
    =/  =app:g  `@tas`i.t.path
    =/  n1=node:g
      [i `@tas`i.t `@t`i.t.t]:t.t.path
    =/  n2=node:g
      =+  i.t.t.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.t.t.path)]
        %entity   [%entity `@tas`i `@t`i.t]:t.t.t.t.t.path
      ==
    =/  =tag:g
      ?-  i.t.t.t.t.t.path
        ?(%ship %address)  t.t.t.t.t.t.t.path
        %entity            t.t.t.t.t.t.t.t.path
      ==
    (~(has-tag sg:g graph.state) n1 n2 app tag)
  ==
--