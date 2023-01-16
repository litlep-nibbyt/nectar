/-  *rdb
|%
++  users-table
  =/  =table
    :*  name=%users
        owner=%my-app
        editors=(silt ~[%my-app])
        ::  schema
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
        :~  [~[%id] [~[%id] %.y %.y `%gth]]
            [~[%top-score] [~[%top-score] %.n %.n `%gth]]
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
  =+  (~(create tab [table ~]) initial-data)
  =+  (insert:- ~[~[6 'ben' 0 0 [%l ~]]])
  =+  (insert:- ~[~[7 'tim' 0 0 [%l ~]]])
  =+  (delete:- at-key=~[%id] where=[%s %id %eq 2])
  =+  (select:- at-key=~[%top-score] [%s %top-score %lte 300])
  (project:- at-key=~[%top-score] ~[%id %top-score %last-score])
::
++  bigger-table
  =/  =table
    :*  name=%big
        owner=%my-app
        editors=(silt ~[%my-app])
        ::  schema
        %-  ~(gas by *(map term column-type))
        :~  [%id [0 | %ud]]
            [%rank [1 | %ud]]
        ==
        primary-key=~[%id]
        ::  indices
        %-  ~(gas by *(map (list term) key-type))
        :~  [~[%id] [~[%id] %.y %.y `%gth]]
            [~[%rank] [~[%rank] %.n %.y `%lth]]
        ==
        ~
    ==
  =/  initial-data=(list row)
    %+  turn  (gulf 0 100.000)
    |=  i=@
    ~[i (mul 2 i)]
  =+  (~(create tab [table ~]) initial-data)
  =+  %+  select:-  at-key=~[%id]
      [%and [%s %id %gte 5.000] [%s %rank %lte 10.020]]
  (get-rows:- at-key=~[%id])
::
++  indirect-atom-table
  =/  =table
    :*  name=%big
        owner=%my-app
        editors=(silt ~[%my-app])
        ::  schema
        %-  ~(gas by *(map term column-type))
        :~  [%id [0 | %ud]]
            [%rank [1 | %ud]]
        ==
        primary-key=~[%id]
        ::  indices
        %-  ~(gas by *(map (list term) key-type))
        :~  [~[%id] [~[%id] %.y %.y `%gth]]
            [~[%rank] [~[%rank] %.n %.y `%lth]]
        ==
        ~
    ==
  =/  initial-data=(list row)
    %+  turn  (gulf 0 100.000)
    |=  i=@
    ~[(add i (bex 32)) (mul 2 i)]
  =+  (~(create tab [table ~]) initial-data)
  =+  %+  select:-  at-key=~[%id]
      [%and [%s %id %gte (add 5.000 (bex 32))] [%s %rank %lte 10.020]]
  (get-rows:- at-key=~[%id])
::
::  table edit engine
::
++  tab
  =>  |%
      ++  comparators  (map term comparator2)
      ++  comparator2  $_  |~  [* *]  ?
      --
  =|  [=table =comparators]
  |%
  ::  TODO figure this out
  ::  ++  add-comparator
  ::    |=  [label=term cmp=comparator2]
  ::    =.  comparators
  ::      (~(put by comparators) label cmp)
  ::    +>.$
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
    ::  primary key must be unique
    ::
    ?>  .=  1
        %-  lent
        %+  skim  ~(tap by indices.table)
        |=  [(list term) key-type]
        primary
    ?>  &(primary unique):(~(got by indices.table) primary-key.table)
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
      %-  ~(gas by *(map (list term) record))
      %+  turn  ~(tap by indices.table)
      |=  [name=(list term) key-type]
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
  ::  produces a list of rows as a "final result"
  ::  for a query
  ::
  ++  get-rows
    |=  at-key=(list term)
    ~&  >  "returning rows"
    ~>  %bout
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
      ?~  clustered.key-type
        ::  map
        (~(gas by *(map key row)) lis)
      ::  mop
      =/  cmp  (make-cluster-arm u.clustered.key-type)
      %+  gas:((on key row) cmp)
      *((mop key row) cmp)  lis
    :-  %|
    ?~  clustered.key-type
      ::  jar
      =/  jar  *(jar key row)
      |-
      ?~  lis  jar
      $(lis t.lis, jar (~(add ja jar) i.lis))
    ::  mop-jar
    =/  cmp  (make-cluster-arm u.clustered.key-type)
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
      ?~  clustered.key-type
        ?+    -.s.where
            (lis)
        ::
            %eq
          ?:  ?=(%& -.rec)
            ?~  res=(~(get by p.rec) ~[+.s.where])
              %&^~
            %&^[[~[+.s.where] u.res] ~ ~]
          %|^[[~[+.s.where] (~(get ja p.rec) ~[+.s.where])] ~ ~]
        ::
            %not
          ?:  ?=(%& -.rec)
            %&^(~(del by `(map key row)`p.rec) ~[+.s.where])
          %|^(~(del by `(map key (list row))`p.rec) ~[+.s.where])
        ==
      =/  cmp  (make-cluster-arm u.clustered.key-type)
      ?+    -.s.where
          (lis)
      ::
          %eq
        ?:  ?=(%& -.rec)
          =/  m  ((on key row) cmp)
          ?~  res=(get:m p.rec ~[+.s.where])
            %&^~
          %&^[[~[+.s.where] u.res] ~ ~]
        =/  mj  ((on key (list row)) cmp)
        %|^[[~[+.s.where] (get:mj p.rec ~[+.s.where])] ~ ~]
      ::
          %not
        ?:  ?=(%& -.rec)
          =/  m  ((on key row) cmp)
          %&^+:(del:m p.rec ~[+.s.where])
        =/  mj  ((on key (list row)) cmp)
        %|^+:(del:mj p.rec ~[+.s.where])
      ::
          ?(%gte %lte %gth %lth)
        =/  m   ((on key row) cmp)
        =/  mj  ((on key (list row)) cmp)
        ::  mop lot
        ::  see which way mop is ordered (g or l)
        ::  and combine that with our comparator
        ::  to correctly slice the ordered map
        ::  type information hates us here for some reason
        ?:  ?=(?(%gte %gth) u.clustered.key-type)
          ::  mop ordered large -> small
          =/  lot-params
            ?-  -.s.where
              %gte  [~ `~[(dec +.s.where)]]
              %gth  [~ `~[+.s.where]]
              %lte  [`~[+(+.s.where)] ~]
              %lth  [`~[+.s.where] ~]
            ==
          ?:  ?=(%& -.rec)
            %&^(lot:m p.rec lot-params)
          %|^(lot:mj p.rec lot-params)
        ::
        ?:  ?=(?(%lth %lth) u.clustered.key-type)
          ::  mop ordered small -> large
          =/  lot-params
            ?-  -.s.where
              %gte  [`~[(dec +.s.where)] ~]
              %gth  [`~[+.s.where] ~]
              %lte  [~ `~[+(+.s.where)]]
              %lth  [~ `~[+.s.where]]
            ==
          ?:  ?=(%& -.rec)
            %&^(lot:m p.rec lot-params)
          %|^(lot:mj p.rec lot-params)
        ::  default case
        (lis)
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
      ?~  clustered.key-type
        ?:  ?=(%& -.rec1)
          ?>  ?=(%& -.rec2)
          ::  map
          %&^(~(uni by p.rec1) p.rec2)
        ?>  ?=(%| -.rec2)
        ::  jar
        %|^(uni-jar p.rec1 p.rec2)
      =/  cmp  (make-cluster-arm u.clustered.key-type)
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
        ?~  clustered.key-type
          ::  map
          |-
          ?~  lis  record
          $(lis t.lis, p.record (~(put by p.record) i.lis))
        ::  mop
        ?>  ?=(%& -.record)
        =/  cmp  (make-cluster-arm u.clustered.key-type)
        =/  m    ((on key row) cmp)
        |-
        ?~  lis  record
        $(lis t.lis, p.record (put:m p.record i.lis))
      ?>  ?=(%| -.record)
      ?~  clustered.key-type
        ::  jar
        |-
        ?~  lis  record
        $(lis t.lis, p.record (~(add ja p.record) i.lis))
      ::  mop-jar
      =/  cmp  (make-cluster-arm u.clustered.key-type)
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
    ?~  clustered.key-type
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
  --
::  record selection stuff
:: =/  best=(unit record)
::       |-
::       ?-    -.where
::           %n  ~
::       ::
::           %s  (~(get by records.table) ~[c.where])
::       ::
::           %d
::         ?^  good=(~(get by records.table) ~[c1.where c2.where])
::           good
::         ?^  next-good=(~(get by records.table) ~[c2.where c1.where])
::           next-good
::         ~
::       ::
::           ?(%and %or)
::         =/  good=(unit record)  $(where a.where)
::         ?^  good  good
::         $(where b.where)
::       ==
::
::       %project
::     ::  returns a table with some subset of columns
::     ^+  table
::     ::  choose which record to use (optimization)
::     =/  rec=record  (~(got by records.table) primary-key.table)
::     =/  indices=(list @)
::       %+  turn  ~(tap in cols.q)
::       |=  =term
::       index:(~(got by schema.table) term)
::     =.  schema.table
::       %-  ~(gas by *(map term column))
::       =<  p
::       %^  spin  ~(tap in cols.q)  0
::       |=  [=term i=@]
::       =/  col  (~(got by schema.table) term)
::       [[term col(index i)] +(i)]
::     :^    name.table
::         schema.table
::       primary-key.table
::     %+  ~(put by records.table)  primary-key.table
::     %-  ~(gas by *record)
::     %+  turn  ~(tap by rec)
::     |=  [=key =row]
::     :-  key
::     %+  turn  indices
::     |=  i=@
::     (snag i row)


::       %cross-product
::     ::  combine two tables
::     =/  with=^table
::       ?@  with.q
::         (~(got by tables.db) with.q)
::       $(q with.q)
::     :-  (cat 3 name.table (cat 3 '-' name.with))
::     ::  create schema for new table by combining each
::     ::  TODO better primary key stuff
::     =/  l  ~(wyt by schema.table)
::     =/  n1  (cat 3 name.table '-')
::     =/  n2  (cat 3 name.with '-')
::     :+  %-  ~(gas by *(map term column))
::         %+  welp
::           %+  turn  ~(tap by schema.table)
::           |=  [=term =column]
::           [(cat 3 n1 term) column]
::         %+  turn  ~(tap by schema.with)
::         |=  [=term =column]
::         :-  (cat 3 n2 term)
::         column(index (add index.column l), primary.key %.n)
::       %id
::     ::  just handling primary key record
::     =/  rec1  (~(got by records.table) primary-key.table)
::     =/  rec2  (~(got by records.with) primary-key.with)
::     %-  ~(gas by *(map term record))
::     :_  ~
::     :-  %id
::     ^-  record
::     %-  ~(gas by *record)
::     %-  zing
::     =<  p
::     %^  spin  ~(tap by rec1)  0
::     |=  [a=[=key =row] i=@]
::     ^-  [(list [key row]) @]
::     %^  spin  ~(tap by rec2)  i
::     |=  [b=[=key =row] j=@]
::     [[j (weld row.a row.b)] +(j)]
::   ::
::       %union
::     ::  combine two tables, if possible
::     ::  TODO validation stuff, assumes matching schemae
::     =/  with=^table
::       ?@  with.q
::         (~(got by tables.db) with.q)
::       $(q with.q)
::     :^    name.table
::         schema.table
::       primary-key.table
::     %+  ~(put by records.table)  primary-key.table
::     %-  ~(uni by (~(got by records.table) primary-key.table))
::     (~(got by records.with) primary-key.with)
::   ::
::       %difference
::     ::  get the difference between two tables
::     ::  TODO validation stuff, assumes matching schemae
::     =/  with=^table
::       ?@  with.q
::         (~(got by tables.db) with.q)
::       $(q with.q)
::     :^    name.table
::         schema.table
::       primary-key.table
::     %+  ~(put by records.table)  primary-key.table
::     %-  ~(dif by (~(got by records.table) primary-key.table))
::     (~(got by records.with) primary-key.with)
::   ::
::       %theta-join
::     ::  cross-product on two tables then select
::     $(q [%select [%cross-product table.q with.q] where.q])
::   ==
:: ::
:: ++  valid-row
::   |=  [sch=(list column) =row]
::   ^-  ?
::   ?>  =((lent sch) (lent row))
::   |-
::   ?~  row  %.y
::   ?~  sch  %.y
::   ?:  optional.i.sch
::     ?.  ?=((unit @) i.row)  %.n
::     $(row t.row, sch t.sch)
::   ?:  ?=(?(%ud %ux %da %t %f) column-type.i.sch)
::     ?.  ?=(@ i.row)  %.n
::     $(row t.row, sch t.sch)
::   =/  sof
::     %-  soft
::     ?-  column-type.i.sch
::       %list  (list value)
::       %set   (set value)
::       %map   (map value value)
::       %blob  *
::     ==
::   ?~  (sof +.i.row)  %.n
::   ?.  =(-.i.row column-type.i.sch)  %.n
::   $(row t.row, sch t.sch)
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
  |=  [=selector =value]
  ^-  ?
  ?:  ?=(%custom -.selector)
    (gat.selector value)
  ?:  ?=(%unit -.selector)
    ?>  ?=((unit @) value)
    (gat.selector value)
  ?>  ?=(@ value)
  ?-  -.selector
    %eq    =(value +.selector)
    %not   !=(value +.selector)
    %gte   (gte value +.selector)
    %lte   (lte value +.selector)
    %gth   (gth value +.selector)
    %lth   (lth value +.selector)
    %atom  (gat.selector value)
  ==
::
++  apply-comparator
  |=  [=comparator a=value b=value]
  ^-  ?
  ?@  comparator
    ?>  &(?=(@ a) ?=(@ b))
    ?-  comparator
      %eq    =(a b)
      %not   !=(a b)
      %gte   (gte a b)
      %lte   (lte a b)
      %gth   (gth a b)
      %lth   (lth a b)
    ==
  ?:  ?=(%custom -.comparator)
    (gat.comparator a b)
  ?:  ?=(%unit -.comparator)
    ?>  ?=((unit @) a)
    ?>  ?=((unit @) b)
    (gat.comparator a b)
  ?>  &(?=(@ a) ?=(@ b))
  (gat.comparator a b)
::
++  make-cluster-arm
  |=  =comparator
  ^-  $-([key key] ?)
  ?@  comparator
    |=  [k1=key k2=key]
    =+  a=(head k1)
    =+  b=(head k2)
    ?>  &(?=(@ a) ?=(@ b))
    ?-  comparator
      %eq   !!
      %not  !!
      %gte  (gte a b)
      %lte  (lte a b)
      %gth  (gth a b)
      %lth  (lth a b)
    ==
  ::  not currently handling custom comparators
  !!
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