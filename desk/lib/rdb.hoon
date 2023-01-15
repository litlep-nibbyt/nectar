/-  *rdb
|%
++  users-table
  =/  score-cmp
    |=  [s1=key s2=key]
    ^-  ?
    %+  gth
      (fall ;;((unit @) (head s1)) 0)
    (fall ;;((unit @) (head s2)) 0)
  =/  =table
    :*  name=%users
        owner=%my-app
        editors=(silt ~[%my-app])
        ::  schema
        %-  ~(gas by *(map term column-type))
        :~  [%id [0 | %ud]]
            [%name [1 | %t]]
            [%score [2 & %ud]]
            [%frens [3 | %list]]
        ==
        primary-key=~[%id]
        ::  indices
        %-  ~(gas by *(map (list term) key-type))
        :~  [~[%id] [~[%id] %.y %.y ~]]
            [~[%scores] [~[%score] %.n %.n `score-cmp]]
        ==
        ~
    ==
  =/  initial-data=(list row)
    :~  ~[0 'nick' `100 [%l ~['ben']]]
        ~[1 'drew' `300 [%l ~['ben' 'nick']]]
        ~[2 'will' `300 [%l ~['ben']]]
        ~[3 'tobias' `1.000 [%l ~['ben']]]
        ~[4 'christian' `1.500 [%l ~['ben']]]
        ~[5 'hocwyn' `1.200 [%l ~['ben']]]
    ==
  =+  (create:(tab table) initial-data)
  =+  (insert:(tab -) ~[~[6 'ben' ~ [%l ~]]])
  =+  (delete:(tab -) [%s %id [%eq 2]])
  %-  select:(tab -)
  :+  %or
    [%s %score [%unit |=(s=(unit @ud) (gte (fall s 0) 300))]]
  [%s %name [%eq 'ben']]
::
::  table edit engine
::
++  tab
  |*  =table
  ::  TODO figure this out
  ::  =>  |%
  ::      ++  comparators  (map term comparator)
  ::      ++  comparator  $_  ^|  |=([mold mold] *?)
  ::      --
  ::  =|  comparators
  |%
  ++  create
    |=  rows=(list row)
    ~&  >  "making table"
    ~>  %bout
    ^+  table
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
    %=    table
        records
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
      :-  name
      ?:  unique
        :-  %&  ::  unique key
        ?~  clustered
          ::  map
          %-  ~(gas by *(map key row))
          lis
        ::  mop
        %+  gas:((on key row) u.clustered)
          *((mop key row) u.clustered)
        lis
      :-  %|  ::  non-unique key
      ?~  clustered
        ::  jar
        =/  jar  *(jar key row)
        |-
        ?~  lis  jar
        $(lis t.lis, jar (~(add ja jar) i.lis))
      ::  mop-jar
      =/  mj  ((on key (list row)) u.clustered)
      =/  mop-jar
        *((mop key (list row)) u.clustered)
      |-
      ?~  lis  mop-jar
      %=    $
          lis  t.lis
          mop-jar
        =+  (get:mj mop-jar key.i.lis)
        (put:mj mop-jar key.i.lis [row.i.lis -])
      ==
    ==
  ::
  ::  select looks for most efficient record to use by seeing
  ::  if the relevant columns form an index
  ::
  ++  select
    |=  where=condition
    ~&  >  "performing select"
    ~>  %bout
    ^-  (list row)
    =/  best=(unit record)
      |-
      ?-    -.where
          %n  ~
      ::
          %s  (~(get by records.table) ~[c.where])
      ::
          %d
        ?^  good=(~(get by records.table) ~[c1.where c2.where])
          good
        ?^  next-good=(~(get by records.table) ~[c2.where c1.where])
          next-good
        ~
      ::
          ?(%and %or)
        =/  good=(unit record)  $(where a.where)
        ?^  good  good
        $(where b.where)
      ==
    =/  rec=record
      ?^  best  u.best
      (~(got by records.table) primary-key.table)
    ::
    ::  now, if we have a keyed record for our selector
    ::  we can use map operations directly
    ::  TODO implement that here
    ::
    =/  lis=(list row)
      ?:  ?=(%& -.rec)
        ~(val by p.rec)
      (zing ~(val by p.rec))
    |-
    ?-    -.where
        %s
      ::  single: apply selector on that col
      =/  c  (~(got by schema.table) c.where)
      %+  skim  lis
      |=  =row
      (apply-selector s.where (snag spot.c row))
    ::
        %d
      ::  dual: apply comparator on two cols
      =/  c1  (~(got by schema.table) c1.where)
      =/  c2  (~(got by schema.table) c2.where)
      %+  skim  lis
      |=  =row
      %+  apply-comparator
        c.where
      [(snag spot.c1 row) (snag spot.c2 row)]
    ::
        %n
      ::  no where clause means get everything
      lis
    ::
        %or
      ::  both clauses applied to full record and results merged
      =/  a=(list row)  $(where a.where)
      =/  b=(list row)  $(where b.where)
      (weld a b)
    ::
        %and
      ::  clauses applied sequentially to one record
      $(where b.where, lis $(where a.where)) :: works?
    ==
  ::
  ::  produces a new table with rows inserted across all records
  ::
  ++  insert
    |=  rows=(list row)
    ~&  >  "performing insert"
    ~>  %bout
    ^+  table
    %=    table
        records
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
        =/  m  ((on key row) u.clustered.key-type)
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
      =/  mj  ((on key (list row)) u.clustered.key-type)
      |-
      ?~  lis  record
      %=    $
          lis  t.lis
          p.record
        =+  (get:mj p.record key.i.lis)
        (put:mj p.record key.i.lis [row.i.lis -])
      ==
    ==
  ::
  ::  produces a new table with rows meeting the condition
  ::  deleted across all records. after deleting records,
  ::  needs to rebuild all secondary indices, so deletes
  ::  take a pretty long time
  ::
  ++  delete
    |=  where=condition
    ~&  >  "performing delete"
    ~>  %bout
    ^+  table
    =/  to-delete=(list row)
      (select where)
    =/  remaining=(set row)
      =/  rec  (~(got by records.table) primary-key.table)
      ?>  ?=(%& -.rec)
      (~(dif in (silt ~(val by p.rec))) (silt to-delete))
    (create ~(tap in remaining))
  --
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
::   ::
::       %delete
::     ^+  table
::     =/  rec=record  (~(got by records.table) primary-key.table)
::     =/  selected=^table
::       $(q [%select table.q where.q])
::     =.  records.table
::       %+  ~(put by records.table)  primary-key.table
::       (~(dif by rec) (~(got by records.selected) primary-key.table))
::     table
::   ::
::       %rename
::     ::  rename a column
::     ::  if primary key, rename that too
::     ^+  table
::     =/  col  (~(got by schema.table) old.q)
::     :-  name.table
::     :+  (~(put by (~(del by schema.table) old.q)) new.q col)
::       ?:  =(primary-key.table old.q)
::         new.q
::       primary-key.table
::     records.table
::   ::
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

--