/-  *social-graph
|%
::
::  motivation:
::  I know about a bunch of ships, crypto addresses, and entities.
::  I want to assign arbitrary tags, associated with specific apps, to these.
::  That app can then programmatically write to its tags, while any other
::  app I use can read from them.
::
::  I have contacts app that contains saved metadata by ship, such as
::  irl name, phone number, email address. Contacts app applies a %contacts
::  protocol to ships, which contains in metadata a set of category tags,
::  user-defined.
::
::  Then, in chat app, I can either apply new tags to contacts or quickly get
::  a set of ships with which have a specific tag under the %contacts protocol.
::
::  In documents app, I can piggyback off the %contacts protocol to quickly
::  generate a set of collaborators for a collection or individual document
::  by selecting all ships with a certain tag or grouping of tags. Example:
::  make new document to share with %uqbar-dao, or just &(%uqbar-dao %devs),
::  or &(%uqbar-dao |(%marketing %finance)).
::
::  I cannot put arbitrarily complex data along an edge. If my protocol seeks
::  to assign, say, an uqbar address to a ship as a sort of "address book",
::  it should assign a protocol label and then expose a scry path to give the
::  actual data. Example: I have address 0x1234 for ~zod, so my graph has a
::  directed edge to ~zod with protocol %uqbar-address and no tags. An app
::  then scries local app %uqbar-address with path /~zod to receive [~ 0x1234].
::
::  Creating new protocols vs. just assigning tags in existing protocols is
::  a choice over write control. Right now, a protocol name is equal to an
::  app name. Only that app can add/del tags on that protocol. An app like
::  %contacts will provide its own open API for editing contacts and thus tags,
::  but many apps/protocols will not.
::
::  TODO: flesh out an example case for a globally-attested edge and build
::  ability to handle that into edge/app/tag definitions
::
++  gi  bi:mip              ::  graph engine = mip engine
::
++  sg
  |_  social-graph
  ::
  ::  receive a set of nodes stemming from source node with this tag
  ::  if tag is left unspecified, any node with matching app is given
  ::
  ++  get-nodes
    |=  [from=node =app tag=(unit tag)]
    ^-  (set node)
    ?^  tag
      (~(get ju (~(gut gi edges) app u.tag *nodeset)) from)
    ::  =<  q
    %-  ~(rep by (~(gut by edges) app ~))
    |=  [n=[^tag nodeset] res=(set node)]
    (~(uni in res) (~(get ju +.n) from))
  ::
  ::  receive all node-node relations under app+tag
  ::
  ++  get-nodeset
    |=  [=app =tag]
    ^-  nodeset
    (~(gut by (~(gut by edges) app ~)) tag ~)
  ::
  ::  receive edge associated with a specific node->node
  ::
  ++  get-edge
    |=  [from=node to=node]
    ^-  (unit edge)
    (~(get gi nodes) from to)
  ::
  ::  receive set of tags associated with a node->node edge
  ::  under a specific app. returns ~ if no app at edge
  ::
  ++  get-app
    |=  [from=node to=node =app]
    ^-  (unit (set tag))
    ?^  ap=(~(get gi nodes) from to)
      `(~(get ju u.ap) app)
    ~
  ::
  ::  see if a given relationship exists
  ::
  ++  has-tag
    |=  [from=node to=node =app =tag]
    ^-  ?
    (~(has ju (~(gut gi nodes) from to ~)) app tag)
  ::
  ::  see whether a specific tag is bidirectional or not
  ::
  ++  is-bidirectional
    |=  [n1=node n2=node =app =tag]
    ^-  ?
    =+  edg=(~(gut gi edges) app tag *nodeset)
    ?&  (~(has ju edg) n1 n2)
        (~(has ju edg) n2 n1)
    ==
  ::
  ::  remove all edges attached to a particular node
  ::
  ++  nuke-node
    |=  =node
    ^-  social-graph
    :-  ::  nodes
        %-  ~(run by (~(del by nodes) node))
        |=  m=(map ^node edge)
        (~(del by m) node)
    ::  edges
    %-  ~(run by edges)
    |=  m=(map tag nodeset)
    %-  ~(run by m)
    |=  =nodeset
    %-  ~(run by (~(del by nodeset) node))
    |=  n=(set ^node)
    (~(del in n) node)
  ::
  ::  remove all edges associated with a particular app
  ::
  ++  nuke-app
    |=  =app
    ^-  social-graph
    :-  ::  nodes
        %-  ~(run by nodes)
        |=  m=(map node edge)
        %-  ~(run by m)
        |=  =edge
        (~(del by edge) app)
    ::  edges
    (~(del by edges) app)
  ::
  ::  remove a tag on all edges within a particular app
  ::
  ++  nuke-tag
    |=  [=app =tag]
    ^-  social-graph
    :-  ::  nodes
        %-  ~(run by nodes)
        |=  m=(map node edge)
        %-  ~(run by m)
        |=  =edge
        (~(del ju edge) app tag)
    ::  edges
    %+  ~(put by edges)  app
    (~(del by (~(gut by edges) app ~)) tag)
  ::
  ++  add-tag
    |=  [from=node to=node =app =tag]
    ^-  social-graph
    :-  ::  nodes
        =-  (~(put gi nodes) from to -)
        (~(put ju (~(gut gi nodes) from to ~)) app tag)
    ::  edges
    =-  (~(put gi edges) app tag `nodeset`-)
    (~(put ju (~(gut gi edges) app tag *nodeset)) from to)
  ::
  ++  del-tag
    |=  [from=node to=node =app =tag]
    ^-  social-graph
    :-  ::  nodes
        ::  if this deletion results in an empty edge,
        ::  remove 'to' node from nodes
        ?~  e=(~(del ju `edge`(~(gut gi nodes) from to *edge)) app tag)
          (~(del gi nodes) from to)
        (~(put gi nodes) from to e)
    ::  edges
    =-  (~(put gi edges) app tag `nodeset`-)
    (~(del ju (~(gut gi edges) app tag *nodeset)) from to)
  ::
  ::  replace our own nodeset for a given app+tag
  ::
  ++  replace-nodeset
    |=  [=nodeset =app =tag]
    ^-  social-graph
    ::  first nuke tag for clean slate
    =.  nodes
      %-  ~(run by nodes)
      |=  m=(map node edge)
      %-  ~(run by m)
      |=  =edge
      (~(del ju edge) app tag)
    =/  nl=(list [node node])
      %-  zing
      %+  turn  ~(tap by nodeset)
      |=  [n1=node ns=(set node)]
      %+  turn  ~(tap in ns)
      |=  n2=node
      [n1 n2]
    :-  ::  nodes
        |-
        ?~  nl  nodes
        =+  (~(put ju (~(gut gi nodes) -.i.nl +.i.nl ~)) app tag)
        $(nl t.nl, nodes (~(put gi nodes) -.i.nl +.i.nl -))
    ::  edges
    (~(put gi edges) app tag nodeset)
  --
::
::  pleasant helper function
::
++  in-nodeset
  |=  [no=node ns=nodeset]
  ^-  ?
  =-  (~(has in -) no)
  ^-  (set node)
  %-  ~(uni in ~(key by ns))
  ^-  (set node)
  %-  ~(rep by ns)
  |=  [p=[node (set node)] q=(set node)]
  (~(uni in q) +.p)
--