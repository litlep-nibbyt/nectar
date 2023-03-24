/-  *linedb
|%
++  branch
  =|  [snaps=((mop index commit) lth) head=index]
  |%
  ::
  ++  add-commit
    |=  [author=ship new-snap=snapshot]
    ^+  branch
    =*  commit
      :+  author
        new-snap
      ?:  =(0 head)  (build-diff ~ new-snap)
      (build-diff snapshot:(got:snap-on snaps head) new-snap)
    %=  +>.$
      head   +(head)
      snaps  (put:snap-on snaps +(head) commit)
    ==
  ::
  ++  set-head
    |=  new-head=@ud
    ^+  branch
    ?>  (has:snap-on snaps new-head)
    +>.$(head new-head)
  ::
  ++  build-diff
    |=  [old=snapshot new=snapshot]
    ^-  (map path diff)
    %-  ~(urn by (~(uni by old) new))
    |=  [=path *]
    ^-  diff
    =/  a=file
      ?~(got=(~(get by old) path) *file u.got)
    =/  b=file
      ?~(got=(~(get by new) path) *file u.got)
    (lusk:differ a b (loss:differ a b))
  ::
  ++  read-doc
    |=  =file-name
    ^-  cord 
    %-  of-wain:format
    (~(got by snapshot:(got:snap-on snaps head)) file-name)
  --
--
