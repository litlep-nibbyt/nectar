/-  *linedb
|%
++  repository
  =|  =repo
  |%
  ++  add-branch
    |=  [new=name parent=(unit name)]
    ^+  repository
    =.  parents.repo
      (~(put by parents.repo) new parent)
    ?~  parent
      +>.$(branches.repo (~(put by branches.repo) new [~ 0]))
    =+  (~(got by branches.repo) u.parent)
    +>.$(branches.repo (~(put by branches.repo) new -))
  ::
  ++  add-commit
    |=  [on-branch=name author=ship diffs=(list diff)]
    ^+  repository
    %=    +>.$
        branches.repo
      %+  ~(jab by branches.repo)  on-branch
      |=  =branch
      =/  =commit
        :+  author
          %+  build-snapshot
            ?:  =(0 head.branch)  ~
            snapshot:(got:snap-on [snaps head]:branch)
          diffs
        diffs
      %=  branch
        head   +(head.branch)
        snaps  (put:snap-on snaps.branch +(head.branch) commit)
      ==
    ==
  ::
  ::  do stuff like revert by setting head backwards
  ::
  ++  set-head
    |=  [on-branch=name new-head=@ud]
    ^+  repository
    %=    +>.$
        branches.repo
      %+  ~(jab by branches.repo)
        on-branch
      |=  =branch
      ::  enforce that head can't go beyond highest index
      ?>  (has:snap-on snaps.branch new-head)
      branch(head new-head)
    ==
  ::
  ::  construct new snapshot from old snapshot + list of diffs
  ::
  ++  build-snapshot
    |=  [old=snapshot diffs=(list diff)]
    ^-  snapshot
    ::  iteratively apply diffs to associated docs
    ::  if a diff is for a doc-name we don't have, make that doc
    ::  (?) if a diff removes all lines from a doc, delete (?)
    |-
    ?~  diffs  old
    =*  diff  i.diffs
    %=    $
        diffs  t.diffs
        old
      %+  ~(put by old)
        doc-name.diff
      ?~  d=(~(get by old) doc-name.diff)
        `doc`(put:doc-on *doc [line-num line]:diff)
      `doc`(put:doc-on u.d [line-num line]:diff)
    ==
  ::
  ::  given a branch and doc, gets that doc
  ::
  ++  read-doc
    |=  [on-branch=name =doc-name]
    ^-  cord
    =/  =branch  (~(got by branches.repo) on-branch)
    =+  snapshot:(got:snap-on [snaps head]:branch)
    %-  of-wain:format
    (turn (tap:doc-on (~(got by -) doc-name)) tail)
  --
--