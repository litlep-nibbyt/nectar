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
        ::  indices
        %-  ~(gas by *(map term key-type))
        :~  [%id [~[%id] %.y ~ %.y]]
            [%scores [~[%score] %.n `score-cmp %.n]]
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
  (create:(tab table) initial-data)
::
::  table edit engine
::
++  tab
  |*  =table
  ::  =>  |%
  ::      ++  comparators  (map term comparator)
  ::      ++  comparator  $_  ^|  |=([mold mold] *?)
  ::      --
  ::  =|  comparators
  |%
  ++  create
    |=  rows=(list row)
    ^+  table
    ::
    ::  build a new table
    ::  destroys any existing records
    ::
    ::  can only have 1 primary key
    ::
    ?>  .=  1
        %-  lent
        %+  skim  ~(tap by indices.table)
        |=  [term key-type]
        primary
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
      %-  ~(gas by *(map term record))
      %+  turn  ~(tap by indices.table)
      |=  [name=term key-type]
      ::  TODO handle unique/non
      =/  lis=(list [=key =row])
        %+  turn  rows
        |=  =row
        :_  row
        ::  grab key column(s)
        ^-  key
        %+  turn  cols
        |=  col=term
        %+  snag
          spot:(~(got by schema.table) col)
        row
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
  --
::
:: ++  select-query
::   ^-  query
::   =+  c1=[%atom |=(name=@t |(=(name 'nick') =(name 'hocwyn')))]
::   =+  c2=[%unit |=(s=(unit @ud) ?~(s %.n (gte u.s 500)))]
::   :+  %select
::     table=%users
::   where=[%and [%s %name c1] [%s %score c2]]
:: ::
:: ++  project-query
::   ^-  query
::   :+  %project
::     table=%users
::   cols=(silt `(list term)`~[%id %score])
:: ::
:: ++  insert-query
::   ^-  query
::   :+  %insert
::     table=%users
::   :~  ~[6 'tim' `800 [%l ~['ben']]]
::       ~[7 'ben' `300 [%l ~]]
::       ~[8 'steve' `500 [%l ~['ben']]]
::   ==
:: ::
:: ++  insert-select-query
::   ^-  query
::   :+  %select
::     insert-query
::   where=[%s %score %unit |=(s=(unit @ud) ?~(s %.n (gte u.s 500)))]
:: ::
:: ++  insert-delete-query
::   ^-  query
::   :+  %delete
::     insert-query
::   where=[%s %score %unit |=(s=(unit @ud) ?~(s %.n (lte u.s 1.000)))]
:: ::
:: ++  cross-product-query
::   ^-  query
::   :+  %cross-product
::     %users
::   %messages
:: ::
:: ++  theta-join-query
::   ^-  query
::   :^    %theta-join
::       %users
::     %messages
::   where=[%d %users-name %messages-from %eq]
:: ::
:: ::  engine
:: ::
:: ++  modify-db
::   |=  [db=database q=query]
::   ^-  database
::   =/  new=table  (run-query db q)
::   db(tables (~(put by tables.db) name.new new))
:: ::
:: ++  run-query
::   |=  [db=database q=query]
::   ~>  %bout
::   ^-  table
::   ?:  ?=(%table -.q)
::     (~(got by tables.db) table.q)
::   =/  =table
::     ?@  table.q
::       (~(got by tables.db) table.q)
::     $(q table.q)
::   ?-    -.q
::       %select
::     ::  returns table with only selected records
::     ^+  table
::     ::  choose which record to use (optimization)
::     =/  rec=record  (~(got by records.table) primary-key.table)
::     :^    name.table
::         schema.table
::       primary-key.table
::     %+  ~(put by records.table)  primary-key.table
::     |-  ^-  record
::     ?-    -.where.q
::         %s
::       ::  single: apply selector on that col
::       =/  =column  (~(got by schema.table) c.where.q)
::       %-  ~(gas by *record)
::       %+  skim  ~(tap by rec)
::       |=  [=key =row]
::       %+  apply-selector
::         s.where.q
::       (snag index.column row)
::     ::
::         %d
::       ::  dual: apply comparator on two cols
::       =/  c1  (~(got by schema.table) c1.where.q)
::       =/  c2  (~(got by schema.table) c2.where.q)
::       %-  ~(gas by *record)
::       %+  skim  ~(tap by rec)
::       |=  [=key =row]
::       %+  apply-comparator
::         c.where.q
::       [(snag index.c1 row) (snag index.c2 row)]
::     ::
::         %n
::       ::  no where clause means get everything
::       rec
::     ::
::         %or
::       ::  both clauses applied to full record and results merged
::       (~(uni by $(where.q a.where.q)) $(where.q b.where.q))
::     ::
::         %and
::       ::  clauses applied sequentially to one record
::       $(where.q b.where.q, rec $(where.q a.where.q)) :: works?s
::     ==
::   ::
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
::       %insert
::     ::  returns new table
::     ^+  table
::     ::  insert all rows into table
::     ::  TODO primary key stuff
::     =/  rec=record  (~(got by records.table) primary-key.table)
::     =/  sch=(list column)
::       %+  sort  ~(val by schema.table)
::       |=  [a=[i=@ *] b=[i=@ *]]
::       (lth i.a i.b)
::     |-
::     ?~  rows.q
::       table(records (~(put by records.table) primary-key.table rec))
::     ?.  (valid-row sch i.rows.q)
::       $(rows.q t.rows.q)
::     =/  pri=value
::       =-  (snag - i.rows.q)
::       index:(~(got by schema.table) primary-key.table)
::     $(rows.q t.rows.q, rec (~(put by rec) pri i.rows.q))
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