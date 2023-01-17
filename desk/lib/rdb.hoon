/-  *rdb
|%
++  users-table
  =/  =table
    :*  ::  schema
        %-  ~(gas by *(map term column-type))
        :~  [%id [0 | %ud]]
            [%name [1 | %t]]
            [%top-score [2 | %ud]]
            [%last-score [3 | %ud]]
            [%frens [4 | %list]]
        ==
        primary-key=~[%id]
        ::  indices
        %-  ~(gas by *(map (list term) key-type))
        :~  [~[%id] [~[%id] %.y %.y %.y]]
            [~[%top-score] [~[%top-score] %.n %.n %.n]]
        ==
        ~
    ==
  =/  initial-data=(list row)
    :~  ~[0 'nick' 100 400 [%l ~['ben']]]
        ~[1 'drew' 300 100 [%l ~['ben' 'nick']]]
        ~[2 'will' 300 1.000 [%l ~['ben']]]
        ~[3 'tobias' 1.000 300 [%l ~['ben']]]
        ~[4 'christian' 1.500 500 [%l ~['ben']]]
        ~[5 'hocwyn' 1.200 1.400 [%l ~['ben']]]
    ==
  (~(create tab table) initial-data)
::
++  messages-table
  =/  =table
    :*  ::  schema
        %-  ~(gas by *(map term column-type))
        :~  [%from [0 | %t]]
            [%to [1 | %t]]
            [%message [2 | %t]]
        ==
        primary-key=~[%from]
        ::  indices
        %-  ~(gas by *(map (list term) key-type))
        :~  [~[%from] [~[%from] %.y %.n %.n]]
        ==
        ~
    ==
  =/  initial-data=(list row)
    :~  ~['ben' 'nick' 'aaa']
        ~['nick' 'ben' 'bbb']
        ~['tim' 'drew' 'ccc']
        ~['ben' 'nick' 'ddd']
        ~['nick' 'ben' 'eee']
    ==
  (~(create tab table) initial-data)
::
++  my-db
  =+  ~(. database ~)
  =+  (add-tab:- %users %me users-table)
  (add-tab:- %messages %me messages-table)
::
++  my-query
  =+  (insert:my-db %users %me ~[~[6 'ben' 0 0 [%l ~]]])
  =+  (insert:- %users %me ~[~[7 'tim' 0 0 [%l ~]]])
  =+  (delete:- %users %me where=[%s %id %& %eq 4])
  ::  (run-query:- %me [%select %users where=[%s %id %& %gth 2]])
  %+  run-query:-  %me
  [%theta-join %users %messages where=[%d %l-name %&^%eq %r-from]]
::
::  database engine
::
++  database
  =>  |%
      +$  table-name  term
      +$  owner       term
      +$  tables  (map [table-name owner] _tab)
      ::  stored procedures, computed views here
      --
  =|  =tables
  |%
  ++  add-tab
    |=  [n=table-name o=owner tab=_tab]
    +>.$(tables (~(put by tables) [n o] tab))
  ::
  ++  insert
    |=  [n=table-name o=owner rows=(list row)]
    =/  tab  (~(got by tables) [n o])
    (add-tab n o (insert:tab rows))
  ::
  ++  delete
    |=  [n=table-name o=owner where=condition]
    =/  tab  (~(got by tables) [n o])
    =/  query-key  primary-key.table:tab
    (add-tab n o (delete:tab query-key where))
  ::
  ++  rename
    !!  ::  TODO add to +tab
  ::
  ++  run-query
    |=  [from=owner =query]
    ::  here we make smart choices
    =|  query-key=(list column-name)
    =-  (get-rows:- query-key)
    ^-  _tab
    |-
    =/  left-tab=_tab
      ?@  table.query
        (~(got by tables) [table.query from])
      $(query table.query)
    ?+    -.query  ~|("unsupported query!" !!)
        %select
      =?    query-key
          ?=(~ query-key)
        ::  not smart yet..
        primary-key.table:left-tab
      (select:left-tab query-key where.query)
    ::
        %theta-join
      =?    query-key
          ?=(~ query-key)
        ::  not smart yet..
        primary-key.table:left-tab
      =/  right-tab=_tab
        ?@  with.query
          (~(got by tables) [with.query from])
        $(query with.query)
      =/  with=(pair schema (list row))
        :-  schema.table:right-tab
        (get-rows:right-tab primary-key.table:right-tab)
      (theta-join:left-tab query-key cluster=%.y with where.query)
    ==
  --
::
::  table edit engine
::
++  tab
  =|  =table
  |%
  ++  col
    |%
    ++  ord
      |=  at-key=(list column-name)
      ^-  $-([key key] ?)
      ::  clustered indices must be keyed on single col
      =/  =column-name  (head at-key)
      =/  col=column-type
        (~(got by schema.table) column-name)
      |=  [a=key b=key]
      ?>  &(?=([p=@ ~] a) ?=([p=@ ~] b))
      ?+  typ.col  (lte i.a i.b)
        %rd  (lte:rd i.a i.b)
        %rh  (lte:rh i.a i.b)
        %rq  (lte:rq i.a i.b)
        %rs  (lte:rs i.a i.b)
        %s   !=(--1 (cmp:si i.a i.b))
        ?(%t %ta %tas)  (aor i.a i.b)
      ==
    --
  ::
  ++  create
    |=  rows=(list row)
    ~&  >  "making table"
    ~>  %bout
    ::
    ::  build a new table
    ::  destroys any existing records
    ::
    ::  can only have 1 primary key, must be the indicated one
    ::
    ?>  .=  1
        %-  lent
        %+  skim  ~(tap by indices.table)
        |=  [(list term) key-type]
        primary
    ?>  primary:(~(got by indices.table) primary-key.table)
    ::
    ::  columns must be contiguous from 0
    ::  and have no overlap
    ::
    =/  col-list  ~(tap by schema.table)
    ?>  .=  (gulf 0 (dec (lent col-list)))
        %+  sort
          %+  turn  col-list
          |=  [term column-type]
          spot
        lth
    ::
    ::  make a record for each key
    ::
    =.  records.table
      %-  ~(gas by *(map (list column-name) record))
      %+  turn  ~(tap by indices.table)
      |=  [name=(list column-name) key-type]
      =/  lis=(list [=key =row])
        %+  turn  rows
        |=  =row
        :_  row  ^-  key
        %+  turn  cols
        |=  col=term
        (snag spot:(~(got by schema.table) col) row)
      name^(list-to-record name lis)
    ::  return modified tab core
    +>.$
  ::
  ::  produces a list of rows from a record
  ::
  ++  get-rows
    |=  at-key=(list term)
    ^-  (list row)
    =?    at-key
        ?=(~ at-key)
      primary-key.table
    =/  rec=record  (~(got by records.table) at-key)
    ?:  ?=(%& -.rec)
      ~(val by p.rec)
    (zing ~(val by p.rec))
  ::
  ++  record-to-list
    |=  rec=record
    ^-  (list [key row])
    ?:  ?=(%& -.rec)
      ~(tap by p.rec)
    (tap-jar p.rec)
  ::
  ++  list-to-record
    |=  [at-key=(list term) lis=(list [=key =row])]
    ^-  record
    =/  =key-type
      ?~  at-key
        (~(got by indices.table) primary-key.table)
      (~(got by indices.table) at-key)
    ?:  unique.key-type
      :-  %&
      ?.  clustered.key-type
        ::  map
        (~(gas by *(map key row)) lis)
      ::  mop
      =/  cmp  (ord:col at-key)
      %+  gas:((on key row) cmp)
      *((mop key row) cmp)  lis
    :-  %|
    ?.  clustered.key-type
      ::  jar
      =/  jar  *(jar key row)
      |-
      ?~  lis  jar
      $(lis t.lis, jar (~(add ja jar) i.lis))
    ::  mop-jar
    =/  cmp  (ord:col at-key)
    =/  mj  ((on key (list row)) cmp)
    =/  mop-jar
      *((mop key (list row)) cmp)
    |-
    ?~  lis  mop-jar
    %=    $
        lis  t.lis
        mop-jar
      =+  g=(get:mj mop-jar key.i.lis)
      (put:mj mop-jar key.i.lis [row.i.lis ?~(g ~ u.g)])
    ==
  ::
  ::
  ::  select using a condition
  ::  accepts a key as hint towards which index to use
  ::  produces this core with only the hinted index modified
  ::
  ++  select
    |=  [at-key=(list term) where=condition]
    ~&  >  "performing select"
    ~>  %bout
    =?    at-key
        ?=(~ at-key)
      primary-key.table
    =/  rec=record  (~(got by records.table) at-key)
    =/  =key-type   (~(got by indices.table) at-key)
    ::  if we have a keyed record for our selector,
    ::  we can use map operations directly
    =-  +>.$(records.table (~(put by records.table) at-key -))
    ^-  record
    |-
    ?-    -.where
        %s
      ::  single: apply selector on that col
      =/  c  (~(got by schema.table) c.where)
      =/  lis
        |.
        =/  listed  (record-to-list rec)
        =/  skimmed=(list [=key =row])
          %+  skim  listed
          |=  [=key =row]
          (apply-selector s.where (snag spot.c row))
        (list-to-record at-key skimmed)
      ::  if that col is key:
      ::    - %eq we can just get from map
      ::    - %not we can del from map
      ::    if record is clustered:
      ::      - %gte, %lte, %gth, %lth
      ::        can be lotted from mop
      ?.  =(~[c.where] at-key)  (lis)
      ?.  clustered.key-type
        ?.  ?=(%& -.s.where)  (lis)
        ?+    -.p.s.where
            (lis)
        ::
            %eq
          ?:  ?=(%& -.rec)
            ?~  res=(~(get by p.rec) ~[+.p.s.where])
              %&^~
            %&^[[~[+.p.s.where] u.res] ~ ~]
          %|^[[~[+.p.s.where] (~(get ja p.rec) ~[+.p.s.where])] ~ ~]
        ::
            %not
          ?:  ?=(%& -.rec)
            %&^(~(del by `(map key row)`p.rec) ~[+.p.s.where])
          %|^(~(del by `(map key (list row))`p.rec) ~[+.p.s.where])
        ==
      =/  cmp  (ord:col at-key)
      ?.  ?=(%& -.s.where)  (lis)
      ?+    -.p.s.where
          (lis)
      ::
          %eq
        ?:  ?=(%& -.rec)
          =/  m  ((on key row) cmp)
          ?~  res=(get:m p.rec ~[+.p.s.where])
            %&^~
          %&^[[~[+.p.s.where] u.res] ~ ~]
        =/  mj  ((on key (list row)) cmp)
        %|^[[~[+.p.s.where] (get:mj p.rec ~[+.p.s.where])] ~ ~]
      ::
          %not
        ?:  ?=(%& -.rec)
          =/  m  ((on key row) cmp)
          %&^+:(del:m p.rec ~[+.p.s.where])
        =/  mj  ((on key (list row)) cmp)
        %|^+:(del:mj p.rec ~[+.p.s.where])
      ::
          ?(%gte %lte %gth %lth)
        ::  mop lot
        ::  mop ordered small -> large
        =/  lot-params
          ?-  -.p.s.where
            %gte  [`~[(dec +.p.s.where)] ~]
            %gth  [`~[+.p.s.where] ~]
            %lte  [~ `~[+(+.p.s.where)]]
            %lth  [~ `~[+.p.s.where]]
          ==
        ?:  ?=(%& -.rec)
          =/  m   ((on key row) cmp)
          %&^(lot:m p.rec lot-params)
        =/  mj  ((on key (list row)) cmp)
        %|^(lot:mj p.rec lot-params)
      ==
    ::
        %d
      ::  dual: apply comparator across two cols
      ::  if both cols are keys, can fix one and
      ::  then transform comparator into selector
      ::  such that we get to use map operations
      ::  all the way. (TODO implement)
      ::
      ::  if one or both cols is *not* a key, need
      ::  to traverse all rows.
      =/  c1  (~(got by schema.table) c1.where)
      =/  c2  (~(got by schema.table) c2.where)
      =/  listed  (record-to-list rec)
      =/  skimmed=(list [=key =row])
        %+  skim  listed
        |=  [=key =row]
        %^  apply-comparator  c.where
        (snag spot.c1 row)  (snag spot.c2 row)
      (list-to-record at-key skimmed)
    ::
        %n
      ::  no where clause means get everything
      rec
    ::
        %or
      ::  both clauses applied to full record
      =/  rec1=record  $(where a.where)
      =/  rec2=record  $(where b.where)
      ::  merge two results
      ::  records will share clustered/unique status
      ?.  clustered.key-type
        ?:  ?=(%& -.rec1)
          ?>  ?=(%& -.rec2)
          ::  map
          %&^(~(uni by p.rec1) p.rec2)
        ?>  ?=(%| -.rec2)
        ::  jar
        %|^(uni-jar p.rec1 p.rec2)
      =/  cmp  (ord:col at-key)
      ?:  ?=(%& -.rec1)
        ?>  ?=(%& -.rec2)
        ::  mop
        =/  m  ((on key row) cmp)
        %&^(uni:m p.rec1 p.rec2)
      ?>  ?=(%| -.rec2)
      ::  mop-jar
      %|^(uni-mop-jar p.rec1 p.rec2 cmp)
    ::
        %and
      ::  clauses applied sequentially to one record
      =.  rec  $(where a.where)
      $(where b.where)
    ==
  ::
  ::  produces a new table with rows inserted across all records
  ::
  ++  insert
    |=  rows=(list row)
    ~&  >  "performing insert"
    ~>  %bout
    =.  records.table
      %-  ~(rut by records.table)
      |=  [name=(list term) =record]
      =/  =key-type  (~(got by indices.table) name)
      =/  lis=(list [=key =row])
        %+  turn  rows
        |=  =row
        :_  row  ^-  key
        %+  turn  cols.key-type
        |=  col=term
        (snag spot:(~(got by schema.table) col) row)
      ?:  unique.key-type
        ?>  ?=(%& -.record)
        ?.  clustered.key-type
          ::  map
          |-
          ?~  lis  record
          ~|  "non-unique key on insert"
          ?>  !(~(has by p.record) key.i.lis)
          $(lis t.lis, p.record (~(put by p.record) i.lis))
        ::  mop
        ?>  ?=(%& -.record)
        =/  cmp  (ord:col name)
        =/  m    ((on key row) cmp)
        |-
        ?~  lis  record
        ~|  "non-unique key on insert"
        ?>  !(has:m p.record key.i.lis)
        $(lis t.lis, p.record (put:m p.record i.lis))
      ?>  ?=(%| -.record)
      ?.  clustered.key-type
        ::  jar
        |-
        ?~  lis  record
        $(lis t.lis, p.record (~(add ja p.record) i.lis))
      ::  mop-jar
      =/  cmp  (ord:col name)
      =/  mj   ((on key (list row)) cmp)
      |-
      ?~  lis  record
      %=    $
          lis  t.lis
          p.record
        =+  (get:mj p.record key.i.lis)
        (put:mj p.record key.i.lis [row.i.lis -])
      ==
    +>.$
  ::
  ::  produces a new table with rows meeting the condition
  ::  deleted across all records. after deleting records,
  ::  needs to rebuild all secondary indices, so deletes
  ::  take a pretty long time
  ::
  ++  delete
    |=  [at-key=(list term) where=condition]
    ~&  >  "performing delete"
    ~>  %bout
    =?    at-key
        ?=(~ at-key)
      primary-key.table
    =/  =key-type  (~(got by indices.table) at-key)
    =/  rec        (~(got by records.table) at-key)
    ?.  clustered.key-type
      =/  del  (~(got by records.table:(select at-key where)) at-key)
      ?:  ?=(%& -.rec)
        ?>  ?=(%& -.del)
        ::  map
        (create ~(val by (~(dif by p.rec) p.del)))
      ?>  ?=(%| -.del)
      ::  jar
      ::  %|^(dif-jar p.rec p.del)
      !!
    ::  for mop, rather than defer to select,
    ::  need to perform logical comparison by key and delete
    ::  or if an un-indexed column, must skim list
    ::  TODO implement key optimization
    =/  listed  (record-to-list rec)
    =/  skipped=(list row)
      %+  murn  listed
      |=  [=key =row]
      ?:  (apply-condition schema.table where row)
        ~
      `row
    (create skipped)
  ::
  ::  produces a list of rows along with a schema for interpreting
  ::  those rows, since projection creates a new row-ordering
  ::
  ++  project
    |=  [at-key=(list term) cols=(list term)]
    ~&  >  "performing projection"
    ~>  %bout
    ^-  (pair schema (list row))
    ::  need to iterate through all rows, so no need
    ::  to determine optimal record to pull from?
    :-  %-  ~(gas by *(map term column-type))
        =<  p
        %^  spin  cols  0
        |=  [=term i=@]
        =/  col  (~(got by schema.table) term)
        [[term col(spot i)] +(i)]
    =/  is=(list @)
      %+  turn  cols
      |=  =term
      spot:(~(got by schema.table) term)
    %+  turn  (get-rows at-key)
    |=  =row
    %+  turn  is
    |=(i=@ (snag i row))
  ::
  ::  cross-product: combinatorily join two records
  ::  places the result as a record -- you choose the key
  ::
  ++  cross
    |=  [at-key=(list term) new-key=key-type with=(pair schema (list row))]
    ~&  >  "performing cross-product"
    ~>  %bout
    =/  l  ~(wyt by schema.table)
    =.  schema.table
      %-  ~(gas by *(map term column-type))
      %+  weld
        %+  turn  ~(tap by schema.table)
        |=  [=term c=column-type]
        [(cat 3 'l-' term) c]
      %+  turn  ~(tap by p.with)
      |=  [=term c=column-type]
      [(cat 3 'r-' term) c(spot (add spot.c l))]
    =/  lis=(list [key row])
      %-  zing
      %+  turn  (get-rows at-key)
      |=  l=row
      %+  turn  q.with
      |=  r=row
      =/  grow=row  (weld l r)
      :_  grow  ^-  key
      %+  turn  cols.new-key
      |=  col=column-name
      (snag spot:(~(got by schema.table) col) grow)
    =.  indices.table
      [cols.new-key^new-key ~ ~]
    =.  records.table
      [cols.new-key^(list-to-record cols.new-key lis) ~ ~]
    +>.$(primary-key.table cols.new-key)
  ::
  ::  union: concatenate two records
  ::
  ++  union
    |=  [at-key=(list term) with=(pair schema (list row))]
    ~&  >  "performing union"
    ~>  %bout
    ^-  (pair schema (list row))
    =/  l  ~(wyt by schema.table)
    ::  unlike cross-product, if two columns in schemae
    ::  share the same name, they become the same column
    ::  TODO adjust to get correct spot values
    :-  %-  (~(uno by schema.table) p.with)
        |=  [term c1=column-type c2=column-type]
        ::  if overlap, take type from our table
        [0 |(optional.c1 optional.c2) typ.c1]
    ::  TODO pad rows to get proper alignment
    %+  weld
      (get-rows at-key)
    q.with
  ::
  ::  theta-join: cross-product on two tables, then select
  ::
  ++  theta-join
    |=  [at-key=(list term) cluster=? with=(pair schema (list row)) where=condition]
    ~&  >  "performing theta-join"
    ~>  %bout
    =/  new-key=key-type
      :^    (turn at-key |=(t=term (cat 3 'l-' t)))
          primary=%.y
        unique=%.n
      clustered=cluster
    =.  +>.$  (cross at-key new-key with)
    (select cols.new-key where)
  --
::
++  apply-condition
  |=  [=schema cond=condition =row]
  ^-  ?
  ?-    -.cond
    %n  %.y
  ::
      %s
    =-  (apply-selector s.cond -)
    (snag spot:(~(got by schema) c.cond) row)
  ::
      %d
    =-  (apply-comparator c.cond -)
    :-  (snag spot:(~(got by schema) c1.cond) row)
    (snag spot:(~(got by schema) c2.cond) row)
  ::
      %and
    ?:  $(cond a.cond)
      $(cond b.cond)
    %.n
  ::
      %or
    |($(cond a.cond) $(cond b.cond))
  ==
::
++  apply-selector
  |=  [=selector a=value]
  ^-  ?
  ?.  ?=(%& -.selector)
    (p.selector a)
  ?>  ?=(@ a)
  ?-  -.p.selector
    %eq    =(a +.p.selector)
    %not   !=(a +.p.selector)
    %gte   (gte a +.p.selector)
    %lte   (lte a +.p.selector)
    %gth   (gth a +.p.selector)
    %lth   (lth a +.p.selector)
    %nul   =(~ a)
  ==
::
++  apply-comparator
  |=  [=comparator a=value b=value]
  ^-  ?
  ?.  ?=(%& -.comparator)
    (p.comparator a b)
  ?>  &(?=(@ a) ?=(@ b))
  ?-  p.comparator
    %eq    =(a b)
    %not   !=(a b)
    %gte   (gte a b)
    %lte   (lte a b)
    %gth   (gth a b)
    %lth   (lth a b)
  ==
::
::  missing jar utils
::
++  tap-jar
  |=  j=(tree [key (list row)])
  ^-  (list [key row])
  %-  zing
  %+  turn  ~(tap by j)
  |=  [k=key l=(list row)]
  (turn l |=(r=row [k r]))
::
++  uni-jar
  |=  [a=(tree [=key rows=(list row)]) b=(tree [=key rows=(list row)])]
  ^+  a
  ?~  b  a
  ?~  a  b
  ?:  =(key.n.a key.n.b)
    ::  if keys match, instead of overriding item in a,
    ::  weld together two lists and remove duplicates
    ::  this is likely very slow. so, simply don't make
    ::  %or queries that overlap!
    :_  [l=$(a l.a, b l.b) r=$(a r.a, b r.b)]
    n=[key.n.a ~(tap in (silt (weld rows.n.a rows.n.b)))]
  ?:  (mor key.n.a key.n.b)
    ?:  (gor key.n.b key.n.a)
      $(l.a $(a l.a, r.b ~), b r.b)
    $(r.a $(a r.a, l.b ~), b l.b)
  ?:  (gor key.n.a key.n.b)
    $(l.b $(b l.b, r.a ~), a r.a)
  $(r.b $(b r.b, l.a ~), a l.a)
::
::  mop-jar utils
::
++  uni-mop-jar
  |=  $:  a=(tree [=key rows=(list row)])
          b=(tree [=key rows=(list row)])
          cmp=$-([key key] ?)
      ==
  ^+  a
  ?~  b  a
  ?~  a  b
  ?:  =(key.n.a key.n.b)
    :_  [l=$(a l.a, b l.b) r=$(a r.a, b r.b)]
    n=[key.n.a ~(tap in (silt (weld rows.n.a rows.n.b)))]
  ?:  (mor key.n.a key.n.b)
    ?:  (cmp key.n.b key.n.a)
      $(l.a $(a l.a, r.b ~), b r.b)
    $(r.a $(a r.a, l.b ~), b l.b)
  ?:  (cmp key.n.a key.n.b)
    $(l.b $(b l.b, r.a ~), a r.a)
  $(r.b $(b r.b, l.a ~), a l.a)
--