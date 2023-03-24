/+  *test, g=social-graph
|%
++  test-1  ^-  tang  ::  add-tag, get-nodes, get-nodeset, get-edge
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/other/edge)
  ;:  weld
    %+  expect-eq
      !>((~(gas in *(set node:g)) ~[ship+~bus ship+~nec]))
    !>((~(get-nodes sg:g graph) ship+~zod %tests ~))
  ::
    %+  expect-eq
      !>((~(gas in *(set node:g)) ~[ship+~bus ship+~nec]))
    !>((~(get-nodes sg:g graph) ship+~zod %tests `/my/edge))
  ::
    %+  expect-eq
      !>(*(set node:g))
    !>((~(get-nodes sg:g graph) ship+~zod %tests `/not/my/edge))
  ::
    %+  expect-eq
      !>(*nodeset:g)
    !>((~(get-nodeset sg:g graph) %tests /not/my/edge))
  ::
    %+  expect-eq
      !>  ^-  nodeset:g
      (~(put ju *nodeset:g) ship+~zod ship+~bus)
    !>((~(get-nodeset sg:g graph) %tests /my/other/edge))
  ::
    %+  expect-eq
      !>  ^-  (unit edge:g)  :-  ~
      =+  (~(put ju *edge:g) %tests /my/edge)
      (~(put ju -) %tests /my/other/edge)
    !>((~(get-edge sg:g graph) ship+~zod ship+~bus))
  ::
    %+  expect-eq
      !>  ^-  (unit edge:g)  ~
    !>((~(get-edge sg:g graph) ship+~zod ship+~fun))
  ==
::
++  test-2  ^-  tang  ::  add-tag, get-nodes, get-nodeset, get-edge, get-app-tags
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/other/edge)
  =.  graph  (~(add-tag sg:g graph) entity+tests+'my entity' ship+~zod %tests /funky/town)
  =.  graph  (~(add-tag sg:g graph) ship+~bus ship+~bus %tests /self/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~bus ship+~zod %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %other-app /whoa)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %other-app /hey/now)
  ;:  weld
    %+  expect-eq
      !>((~(gas in *(set node:g)) ~[ship+~bus ship+~zod]))
    !>((~(get-nodes sg:g graph) ship+~bus %tests ~))
  ::
    %+  expect-eq
      !>((~(gas in *(set tag:g)) ~[/my/edge /my/other/edge /self/edge /funky/town]))
    !>((~(get-app-tags sg:g graph) %tests))
  ::
    %+  expect-eq
      !>(*(set tag:g))
    !>((~(get-app-tags sg:g graph) %not-an-app))
  ::
    %+  expect-eq
      !>((~(gas in *(set tag:g)) ~[/whoa /hey/now]))
    !>((~(get-app-tags sg:g graph) %other-app))
  ::
    %+  expect-eq
      !>((~(gas in *(set node:g)) ~[ship+~bus ship+~nec]))
    !>((~(get-nodes sg:g graph) ship+~zod %tests ~))
  ::
    %+  expect-eq
      !>((~(gas in *(set node:g)) ~[ship+~bus ship+~nec]))
    !>((~(get-nodes sg:g graph) ship+~zod %tests `/my/edge))
  ::
    %+  expect-eq
      !>(*(set node:g))
    !>((~(get-nodes sg:g graph) ship+~zod %tests `/not/my/edge))
  ::
    %+  expect-eq
      !>(*nodeset:g)
    !>((~(get-nodeset sg:g graph) %tests /not/my/edge))
  ::
    %+  expect-eq
      !>  ^-  nodeset:g
      (~(put ju *nodeset:g) ship+~zod ship+~bus)
    !>((~(get-nodeset sg:g graph) %tests /my/other/edge))
  ::
    %+  expect-eq
      !>  ^-  (unit edge:g)  :-  ~
      =+  (~(put ju *edge:g) %tests /my/edge)
      (~(put ju -) %tests /my/other/edge)
    !>((~(get-edge sg:g graph) ship+~zod ship+~bus))
  ::
    %+  expect-eq
      !>  ^-  (unit edge:g)  ~
    !>((~(get-edge sg:g graph) ship+~zod ship+~fun))
  ==
::
++  test-3  ^-  tang  ::  has-tag, is-bidirectional
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/other/edge)
  =.  graph  (~(add-tag sg:g graph) entity+tests+'my entity' ship+~zod %tests /funky/town)
  =.  graph  (~(add-tag sg:g graph) ship+~bus ship+~bus %tests /self/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~bus ship+~zod %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %other-app /whoa)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %other-app /hey/now)
  ;:  weld
    %+  expect-eq
      !>(%.y)
    !>((~(has-tag sg:g graph) ship+~bus ship+~bus %tests /self/edge))
  ::
    %+  expect-eq
      !>(%.n)
    !>((~(has-tag sg:g graph) ship+~bus ship+~zod %tests /self/edge))
  ::
    %+  expect-eq
      !>(%.y)
    !>((~(has-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge))
  ::
    %+  expect-eq
      !>(%.n)
    !>((~(has-tag sg:g graph) ship+~nec ship+~zod %tests /my/edge))
  ::
    %+  expect-eq
      !>(%.y)
    !>((~(is-bidirectional sg:g graph) ship+~zod ship+~bus %tests /my/edge))
  ::
    %+  expect-eq
      !>(%.y)
    !>((~(is-bidirectional sg:g graph) ship+~bus ship+~bus %tests /self/edge))
  ==
::
++  test-4  ^-  tang  ::  add-tag, del-tag
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(del-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(del-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(del-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  %+  expect-eq
    !>(*social-graph:g)
  !>(graph)
::
++  test-5  ^-  tang  ::  add-tag, nuke-node
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(nuke-node sg:g graph) ship+~zod)
  %+  expect-eq
    !>  ^-  social-graph:g
    =/  res  *social-graph:g
    (~(add-tag sg:g res) ship+~nec ship+~bus %tests /my/edge)
  !>(graph)
::
++  test-6  ^-  tang  ::  add-tag, nuke-tag
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %other-app /my/edge)
  =.  graph  (~(nuke-tag sg:g graph) %tests /my/edge)
  %+  expect-eq
    !>  ^-  social-graph:g
    =/  res  *social-graph:g
    (~(add-tag sg:g res) ship+~nec ship+~bus %other-app /my/edge)
  !>(graph)
::
++  test-7  ^-  tang  ::  add-tag, nuke-top-level-tag
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge/2)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge/3)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %other-app /my/edge)
  =.  graph  (~(nuke-top-level-tag sg:g graph) %tests %my)
  %+  expect-eq
    !>  ^-  social-graph:g
    =/  res  *social-graph:g
    (~(add-tag sg:g res) ship+~nec ship+~bus %other-app /my/edge)
  !>(graph)
::
++  test-8  ^-  tang  ::  add-tag, replace-nodeset
  =/  graph  *social-graph:g
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~zod ship+~nec %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %tests /my/edge)
  =.  graph  (~(add-tag sg:g graph) ship+~nec ship+~bus %other-app /my/edge)
  =.  graph  %^  ~(replace-nodeset sg:g graph)
               (~(put ju *nodeset:g) ship+~fun ship+~dev)
             %tests  /my/edge
  %+  expect-eq
    !>  ^-  social-graph:g
    =/  res  *social-graph:g
    =.  res  (~(add-tag sg:g res) ship+~nec ship+~bus %other-app /my/edge)
    (~(add-tag sg:g res) ship+~fun ship+~dev %tests /my/edge)
  !>(graph)
--