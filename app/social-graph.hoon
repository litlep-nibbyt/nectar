/+  verb, dbug, default-agent,  io=agentio,
    g=social-graph, *mip
|%
::
::  %social-graph agent state
::
+$  state
  $:  graph=_social-graph:g
      perms=(map app:g permission-level:g)
      trackers=(map app:g (jug tag:g dock))  ::  TODO make SSS
      tracking=(map [app:g tag:g] @p)        ::  tags we're tracking from others
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
=|  =state
=<  |_  =bowl:gall
    +*  this  .
        hc    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init  `this(state [*_social-graph:g ~ ~ ~])
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
          %social-graph-edit    (handle-edit:hc !<(edit:g vase))
          %social-graph-track   (handle-tracker:hc !<(track:g vase))
          %social-graph-update  (handle-update:hc !<(update:g vase))
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
    ^-  (quip card _state)
    ?>  =(our src):bowl
    ::  need this info in bowl for perms
    =/  =app:g  p.edit
    ?:  ?=(%start-tracking -.q.edit)
      ::  we want to sync a tag from another ship's app
      ::  note this will wipe our own representation of this tag
      :_  state(tracking (~(put by tracking.state) [[app tag] source]:q.edit))
      :_  ~
      %+  ~(poke pass:io /start-tracking)
        [source.q.edit %social-graph]
      social-graph-track+!>(`track:g`[%social-graph [%fetch [app tag]:q.edit]])
    ?:  ?=(%stop-tracking -.q.edit)
      ::  we want to STOP syncing a tag from another ship's app
      :_  state(tracking (~(del by tracking.state) [app tag]:q.edit))
      :_  ~
      %+  ~(poke pass:io /start-tracking)
        [source.q.edit %social-graph]
      social-graph-track+!>(`track:g`[%social-graph [%leave [app tag]:q.edit]])
    ::
    ?:  ?=(%set-perms -.q.edit)
      ::  we want to adjust who can sync tags from us for a given app
      ::  if permission level gets stricter, boot trackers if needed.
      =.  trackers.state
        ?-    level.q.edit
            %public   trackers.state
            %private  (~(del by trackers.state) app)
            %only-tagged
          ::  reassemble trackers by going through each tracker ship
          ::  and asserting that they fall within their specific tag
          ::  this is an expensive operation, try to avoid
          =/  my-trackers=(jug tag:g dock)  (~(gut by trackers.state) app ~)
          =/  my-app=(map tag:g nodeset:g)  (~(gut by edges.graph.state) app ~)
          %+  ~(put by trackers.state)  app
          %-  ~(urn by my-trackers)
          |=  [k=tag:g v=(set dock)]
          =/  =nodeset:g  (~(gut by my-app) k ~)
          =/  allowed=(set node:g)
            %-  ~(uni in ~(key by nodeset))
            ^-  (set node:g)
            %-  ~(rep by nodeset)
            |=  [p=[node:g (set node:g)] q=(set node:g)]
            (~(uni in q) +.p)
          %-  ~(gas in *(set dock))
          %+  skim  ~(tap in v)
          |=  [p=@p term]
          (~(has in allowed) [%ship p])
        ==
      `state(perms (~(put by perms.state) app level.q.edit))
    ::
    ::  after add/del/nuke tags, notify all trackers
    ::
    =^  update  graph.state
      ?-  -.q.edit
        ::  type refinement in hoon is broken.
          %add-tag
        :-  [app tag.q.edit]^[%new-tag [from to]:q.edit]
        (add-tag:graph.state from.q.edit to.q.edit app tag.q.edit)
          %del-tag
        :-  [app tag.q.edit]^[%gone-tag [from to]:q.edit]
        (del-tag:graph.state from.q.edit to.q.edit app tag.q.edit)
          %nuke-tag
        :-  [app tag.q.edit]^[%all ~]
        (nuke-tag:graph.state app tag.q.edit)
      ==
    =/  docks=(set dock)
      (~(gut by (~(gut by trackers.state) app ~)) tag=-.+.q.edit ~)
    :_  state
    %+  turn  ~(tap in docks)
    |=  =dock
    %+  ~(poke pass:io /give-update)
    dock  social-graph-update+!>(`update:g`update)
  ::
  ++  handle-tracker
    |=  =track:g
    ^-  (quip card _state)
    ::  assert that request fits permissions
    ?>  ?-  (~(gut by perms.state) app.q.track *permission-level:g)
          %private  =(src our):bowl
          %public   %.y
            %only-tagged
          ::  src.bowl must appear in nodeset under this app+tag
          =/  =nodeset:g  (get-nodeset:graph.state [app tag]:q.track)
          ?:  (~(has by nodeset) [%ship src.bowl])  %.y
          %-  ~(any by nodeset)
          |=  n=(set node:g)
          (~(has in n) [%ship src.bowl])
        ==
    =/  =dock  [src.bowl p.track]
    =,  q.track
    ?-    -.q.track
        %fetch
      ::  give me current state of nodeset at this app+tag,
      ::  AND give future updates
      =+  (~(put ju (~(gut by trackers.state) app ~)) tag dock)
      :_  state(trackers (~(put by trackers.state) app -))
      :_  ~
      %+  ~(poke pass:io /give-update)
        dock
      =+  (get-nodeset:graph.state [app tag])
      social-graph-update+!>(`update:g`[app tag]^[%all -])
    ::
        %track
      ::  give me future updates of nodeset at this app+tag
      =+  (~(put ju (~(gut by trackers.state) app ~)) tag dock)
      `state(trackers (~(put by trackers.state) app -))
    ::
        %leave
       ::  don't give me any more updates of nodeset at this app+tag
      =+  (~(del ju (~(gut by trackers.state) app ~)) tag dock)
      `state(trackers (~(put by trackers.state) app -))
    ==
  ::
  ::  receive an update from someone else's social graph and integrate
  ::  it into our own.
  ::
  ++  handle-update
    |=  =update:g
    ^-  (quip card _state)
    ::  first assert that we are actually tracking updates from them
    ::  their update may *only* modify the app+tag we're tracking
    ?>  =(src.bowl (~(got by tracking.state) p.update))
    ::  incorporate update into our personal graph
    ::  and don't forget to forward the update to those
    ::  who might be tracking from *us*!
    =.  graph.state
      ?-  -.q.update
          %all
        (replace-nodeset:graph.state nodeset.q.update p.update)
      ::
          %new-tag
        (add-tag:graph.state from.q.update to.q.update p.update)
      ::
          %gone-tag
        (del-tag:graph.state from.q.update to.q.update p.update)
      ==
    =/  docks=(set dock)
      (~(gut by (~(gut by trackers.state) app.p.update ~)) tag.p.update ~)
    :_  state
    %+  turn  ~(tap in docks)
    |=  =dock
    %+  ~(poke pass:io /give-update)
    dock  social-graph-update+!>(`update:g`update)
  ::
  ++  handle-scry
    |=  =path
    ^-  (unit (unit cage))
    ?+    path
      ~|("unexpected scry into {<dap.bowl>} on path {<path>}" !!)
        [%x %controller @ ^]
      ::  /controller/[app]/[tag]
      =/  =app:g  `@tas`i.t.t.path
      =/  =tag:g
        ?:  ?=([@ ~] t.t.t.path)
          `@t`i.t.t.t.path
        t.t.t.path
      =+  (~(gut by tracking.state) [app tag] our.bowl)
      ``social-graph-result+!>(`graph-result:g`[%controller -])
    ::
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
          `@t`i.t.t.t.t.t.path
        t.t.t.t.t.path
      =+  (get-nodes:graph.state node app `tag)
      ``social-graph-result+!>(`graph-result:g`[%nodes -])
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
      =+  (get-nodes:graph.state node app ~)
      ``social-graph-result+!>(`graph-result:g`[%nodes -])
    ==
--