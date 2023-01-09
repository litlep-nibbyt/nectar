/-  *rdb
|%
++  my-database
  ^-  database
  :+  %my-app
    (silt ~[%my-app])
  (malt ~[['my-table' my-table]])
::
++  my-table
  ^-  table
  :+  %-  ~(gas by *(map term column))
      :~  [%id [0 [& &] | %ud]]
          [%name [1 [| |] | %t]]
          [%score [2 [| |] & %ud]]
          [%frens [3 [| |] | [%noun %list]]]
      ==
    primary-key=%id
  ::  one index, so one record
  %-  ~(gas by *(map term record))
  :_  ~
  :-  %id
  ^-  record
  %-  ~(gas by *record)
  :~  [0 ~[0 'nick' `100 [%list ~['ben']]]]
      [1 ~[1 'drew' `300 [%list ~['ben']]]]
      [2 ~[2 'will' `700 [%list ~['ben']]]]
      [3 ~[3 'tobias' `1.000 [%list ~['ben']]]]
      [4 ~[4 'christian' `1.500 [%list ~['ben']]]]
      [5 ~[5 'hocwyn' `1.200 [%list ~['ben']]]]
  ==
::
++  my-query
  ^-  query
  =+  c1=[%atom |=(name=@t |(=(name 'nick') =(name 'hocwyn')))]
  =+  c2=[%unit |=(s=(unit @ud) ?~(s %.n (gte u.s 500)))]
  :+  %select
    table='my-table'
  where=[%and [%s %name c1] [%s %score c2]]
::
++  my-query-2
  ^-  query
  :+  %project
    table='my-table'
  cols=(silt `(list term)`~[%id %score])
::
++  insert-query
  ^-  query
  :+  %insert
    table='my-table'
  :~  ~[6 'tim' `800 [%list ~['ben']]]
      ~[7 'ben' `300 [%list ~]]
      ~[8 'steve' `500 [%list ~['ben']]]
  ==
::
++  my-query-3
  ^-  query
  :+  %select
    insert-query
  where=[%s %score %unit |=(s=(unit @ud) ?~(s %.n (gte u.s 500)))]
::
++  my-query-4
  ^-  query
  :+  %delete
    insert-query
  where=[%s %score %unit |=(s=(unit @ud) ?~(s %.n (lte u.s 1.000)))]
::
++  run-query
  |=  [db=database q=query]
  ~>  %bout
  ^-  table
  ?:  ?=(%table -.q)
    (~(got by tables.db) table.q)
  =/  =table
    ?@  table.q
      (~(got by tables.db) table.q)
    $(q table.q)
  ?-    -.q
      %select
    ::  returns table with only selected records
    ^+  table
    ::  choose which record to use (optimization)
    =/  rec=record  (~(got by records.table) primary-key.table)
    :+  schema.table
      primary-key.table
    %+  ~(put by records.table)  primary-key.table
    |-  ^-  record
    ?-    -.where.q
        %s
      ::  term: apply selector on that col
      =/  =column  (~(got by schema.table) t.where.q)
      %-  ~(gas by *record)
      %+  skim  ~(tap by rec)
      |=  [=key =row]
      %^  apply-selector
        s.where.q  column
      (snag index.column row)
    ::
        %n
      ::  no where clause means get everything
      rec
    ::
        %or
      ::  both clauses applied to full record and results merged
      (~(uni by $(where.q a.where.q)) $(where.q b.where.q))
    ::
        %and
      ::  clauses applied sequentially to one record
      $(where.q b.where.q, rec $(where.q a.where.q)) :: works?s
    ==
  ::
      %project
    ::  returns a table with some subset of columns
    ^+  table
    ::  choose which record to use (optimization)
    =/  rec=record  (~(got by records.table) primary-key.table)
    =/  indices=(list @)
      %+  turn  ~(tap in cols.q)
      |=  =term
      index:(~(got by schema.table) term)
    =.  schema.table
      %-  ~(gas by *(map term column))
      =<  p
      %^  spin  ~(tap in cols.q)  0
      |=  [=term i=@]
      =/  col  (~(got by schema.table) term)
      [[term col(index i)] +(i)]
    :+  schema.table
      primary-key.table
    %+  ~(put by records.table)  primary-key.table
    %-  ~(gas by *record)
    %+  turn  ~(tap by rec)
    |=  [=key =row]
    :-  key
    %+  turn  indices
    |=  i=@
    (snag i row)
  ::
      %insert
    ::  returns new table
    ^+  table
    ::  insert all rows into table
    ::  TODO primary key stuff
    ::  TODO validate fits schema
    =/  rec=record  (~(got by records.table) primary-key.table)
    |-
    ?~  rows.q
      table(records (~(put by records.table) primary-key.table rec))
    =/  pri=value
      =-  (snag - i.rows.q)
      index:(~(got by schema.table) primary-key.table)
    $(rows.q t.rows.q, rec (~(put by rec) pri i.rows.q))
  ::
      %delete
    ^+  table
    =/  rec=record  (~(got by records.table) primary-key.table)
    =/  selected=^table
      $(q [%select table.q where.q])
    =.  records.table
      %+  ~(put by records.table)  primary-key.table
      (~(dif by rec) (~(got by records.selected) primary-key.table))
    table
  ==
::
++  apply-selector
  |=  [=selector =column =value]
  ^-  ?
  ?:  ?=(%unit -.selector)
    ?>  ?=((unit @) value)
    (gat.selector value)
  ?:  ?=(%custom -.selector)
    !!
  ?>  ?=(@ value)
  ?-  -.selector
    %eq    =(value +.selector)
    %not   !=(value +.selector)
    %gte   (gte value +.selector)
    %lte   (lte value +.selector)
    %atom  (gat.selector value)
  ==
--