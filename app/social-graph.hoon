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
  ==
+$  card  card:agent:gall
::
::  scry paths
::
::  /controller/[app]/[tag]  <-  returns @p of who we source a tag from
::  /nodes/[app]/[from-node]/[tag]  <-  returns (set node)
::  TODO /edge/[from-node]/[to-node]     <-  returns (unit edge)
::  TODO /app/[app]/[from-node]/[to-node]      <-  returns (unit (set tag))
::  TODO /has-tag/[app]/[from-node]/[to-node]/[tag]        <-  returns ?
::  TODO /bidirectional/[app]/[from-node]/[to-node]/[tag]  <-  returns ?
--
::
^-  agent:gall
%+  verb  &
%-  agent:dbug
::  SSS declarations
=/  subgraph-sub  (mk-subs subgraph ,[%track *])
=/  subgraph-pub  (mk-pubs subgraph ,[%track *])
::
=|  state=state-1
=<  |_  =bowl:gall
    +*  this  .
        hc    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
        da-sub
          =/  da  (da subgraph ,[%track *])
          ~(. da subgraph-sub bowl -:!>(*result:da) -:!>(*from:da))
        du-pub
          =/  du  (du subgraph ,[%track *])
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
        =^  wave  graph.state
          ?-  -.q.edit
              %add-tag
            :-  [%new-edge from.q.edit to.q.edit]
            (~(add-tag sg:g graph.state) from.q.edit to.q.edit app tag.q.edit)
              %del-tag
            :-  [%gone-edge from.q.edit to.q.edit]
            (~(del-tag sg:g graph.state) from.q.edit to.q.edit app tag.q.edit)
              %nuke-tag
            :-  [%gone-tag ~]
            (~(nuke-tag sg:g graph.state) app tag.q.edit)
          ==
        ::  hand out update to subscribers on this app+tag
        =^  cards  subgraph-pub
          =-  (give:du-pub [%track app -] wave)
          ?-(-.q.edit ?(%add-tag %del-tag) tag.q.edit, %nuke-tag tag.q.edit)
        [cards this]
      ::
          %social-graph-track
        =,  !<(track:g vase)
        :_  this  :_  ~
        (surf:da-sub source %social-graph [%track app tag])
      ::
          %sss-on-rock
        =/  msg  !<(from:da-sub (fled vase))
        ?+    -.msg  `this
            [%track @ ^]
          =/  =app:g  ;;(app:g -.+.-.msg)
          =/  =tag:g  ;;(tag:g +.+.-.msg)
          =.  graph.state
            ?~  wave.msg
              ::  if no wave, use rock in msg as setpoint
              %-  ~(replace-nodeset sg:g graph.state)
              [rock.msg app tag]
            ::  integrate wave into our local graph
            ?-    -.u.wave.msg
                %new-edge
              %-  ~(add-tag sg:g graph.state)
              [from.u.wave.msg to.u.wave.msg app tag]
                %gone-edge
              %-  ~(del-tag sg:g graph.state)
              [from.u.wave.msg to.u.wave.msg app tag]
                %gone-tag
              (~(nuke-tag sg:g graph.state) app tag)
            ==
          `this
        ==
      ::
          %sss-to-pub
        =/  msg  !<(into:du-pub (fled vase))
        ?+    -.msg  `this
            [%track @ ^]
          =/  =app:g  ;;(app:g -.+.-.msg)
          =/  =tag:g  ;;(tag:g +.+.-.msg)
          =/  perm  (~(gut by perms.state) app %private)
          ?.  ?|  =(%public perm)
                  ?&  =(%only-tagged perm)
                      ::  src.bowl must appear in nodeset under this app+tag
                      =/  =nodeset:g  (~(get-nodeset sg:g graph.state) app tag)
                      ?:  (~(has by nodeset) [%ship src.bowl])  %.y
                      %-  ~(any by nodeset)
                      |=(n=(set node:g) (~(has in n) [%ship src.bowl]))
              ==  ==
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
          [~ %sss %on-rock @ @ @ %track *]
        =.  subgraph-sub  (chit:da-sub |3:wire sign)
        `this
      ==
    ::
    ++  on-arvo
      |=  [=wire sign=sign-arvo]
      ^-  (quip card _this)
      ?+  wire  `this
        [~ %sss %behn @ @ @ %track *]  [(behn:da-sub |3:wire) this]
      ==
    ::
    ++  on-watch  on-watch:def
    ++  on-leave  on-leave:def
    ++  on-fail   on-fail:def
    --
::
|_  =bowl:gall
++  handle-scry
  |=  =path
  ^-  (unit (unit cage))
  ?+    path
    ~|("unexpected scry into {<dap.bowl>} on path {<path>}" !!)
      [%x %is-installed ~]
    ``json+!>(`json`[%b &])
      [%x %controller @ ^]
    ::  /controller/[app]/[tag]
    =/  =app:g  `@tas`i.t.t.path
    =/  =tag:g  t.t.t.path
    ``social-graph-result+!>(`graph-result:g`[%controller our.bowl])
  ::
      ?([%x %nodes @ ?(%ship %address) @ ^] [%x %nodes @ %entity @ @ ^])
    ::  /nodes/[app]/[from-node]/[tag]
    =/  =app:g  `@tas`i.t.t.path
    =/  =node:g
      =+  i.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.path)]
        %entity   [- [`@tas`i `@t`i.t]:t.t.t.t.path]
      ==
    =/  =tag:g  t.t.t.t.t.path
    =+  (~(get-nodes sg:g graph.state) node app `tag)
    ``social-graph-result+!>(`graph-result:g`[%nodes -])
  ::
      ?([%x %nodes @ ?(%ship %address) @ ~] [%x %nodes @ %entity @ @ ~])
    ::  /nodes/[app]/[from-node]
    =/  =app:g  `@tas`i.t.t.path
    =/  =node:g
      =+  i.t.t.t.path
      ?-  -
        %ship     [- (slav %p i.t.t.t.t.path)]
        %address  [- (slav %ux i.t.t.t.t.path)]
        %entity   [- [`@tas`i `@t`i.t]:t.t.t.path]
      ==
    =+  (~(get-nodes sg:g graph.state) node app ~)
    ``social-graph-result+!>(`graph-result:g`[%nodes -])
  ==
--