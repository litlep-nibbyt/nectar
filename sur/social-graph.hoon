/+  mip
|%
+$  social-graph        ::  note that both `nodes` and `edges` store exactly
  $:  =nodes            ::  the same data. the sg core updates them
      =edges            ::  in tandem, for querying performance.
  ==
::
::  two representations of same data for performant queries
::
+$  nodes  (mip:mip node node edge)
+$  edges  (mip:mip app tag nodeset)
::
+$  app  term
+$  tag  path  :: can be fully qualified scry path
::
+$  node
  $%  [%ship @p]
      [%address @ux]
      [%entity term]    ::  TODO
  ==
::
+$  edge     (jug app tag)
+$  nodeset  (jug node node)
::
::  permissions are app-level: the app uses %set-perms to say whether
::  - %private: only our ship can track tags in our app's graph
::  - %public: anyone can track tags in our app's graph
::  - %only-tagged: only ships that *have* the tag can track *that tag*.
::
+$  permission-level
  $~  %private
  ?(%private %public %only-tagged)
::
::  !! need USERSPACE PERMS to make this right !!
::
+$  edit
  %+  pair  term  ::  the app poking us, for now -- not used for start/stop tracking
  $%  [%add-tag =tag from=node to=node]
      [%del-tag =tag from=node to=node]
      [%nuke-tag =tag]
      ::  if not set, defaults to %private
      [%set-perms level=permission-level]
  ==
::
::  poke with this to indicate that you want to get pushed updates
::
+$  track
  [source=@p =app =tag]
::
+$  graph-result  ::  comes out of scries
  $%  [%controller @p]
      [%nodes (set node)]
      [%edge (unit edge)]
  ==
--
