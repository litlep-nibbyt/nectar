/-  *linedb
|%
++  branch
  =|  [snaps=((mop index commit) lth) head=index]
  |%
  ::
  ++  add-commit
    |=  [author=ship diffs=(list diff)]
    ^+  branch
    =/  =commit
      :+  author
        %+  build-snapshot
          ?:  =(0 head)  ~
          snapshot:(got:snap-on snaps head)
        diffs
      diffs
    %=  +>.$
      head   +(head)
      snaps  (put:snap-on snaps +(head) commit)
    ==
  ::
  ::  do stuff like revert by setting head backwards
  ::
  ++  set-head
    |=  new-head=@ud
    ^+  branch
    ::  enforce that head can't go beyond highest index
    ?>  (has:snap-on snaps new-head)
    +>.$(head new-head)
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
    |=  [=doc-name]
    ^-  cord
    =+  snapshot:(got:snap-on snaps head)
    %-  of-wain:format
    (turn (tap:doc-on (~(got by -) doc-name)) tail)
  --
--
