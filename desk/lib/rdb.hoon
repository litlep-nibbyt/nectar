/-  *rdb
|%
::
::  test data
::
+$  my-schema
  [id=@ name=@t score=@ud]
::
++  my-table
  ^-  table
  =/  fields
    %-  ~(gas by *(map term iota))
    ~[[%id [%ud *@ud]] [%name [%t *@t]] [%score [%ud *@ud]]]
  =/  prim  %id
  =/  records
    %-  ~(gas by *(map @ record))
    :~  [0 'nick' 100]
        [1 'drew' 700]
        [2 'will' 1.000]
    ==
  ['my-table' fields prim records]
::
++  my-db
  :+  %my-app
    (silt ~[%my-app])
  (malt ~[['my-table' my-table]])
::
++  my-selector-1
  |=  rec=my-schema
  ^-  ?
  (gte score.rec 500)
::
++  my-projector
  |=  rec=my-schema
  [id.rec name.rec]
::
++  my-query
  [%select from='my-table' ~[my-selector-1]]
::
::  table engine
::
++  tab
  |*  [schema=mold]
  =>
    |%
    +$  selector
      $_  ^|  |=(schema *?)
    ::
    +$  projector
      $_  ^|  |=(schema **)
    ::
    ::  +$  joiner
    ::    $_  ^|  |=([a=schema b=schema] *?)
    --
  |%
  ++  select
    ::  return records which match all selectors
    |=  [=table conds=(list selector)]
    ^-  (map @ record)
    %-  ~(gas by *(map @ record))
    %+  skim  ~(tap by records.table)
    |=  r=[@ record]
    %+  levy  conds
    |=  s=selector
    (s !<(schema !>(r)))
  ::
  ++  project
    ::  return all records transformed via expression
    |=  [=table =projector]
    ^-  (map @ record)
    %-  ~(rut by records.table)
    |=  r=[@ record]
    (projector !<(schema !>(r)))
  ::
  ++  insert
    ::  return table with new record(s)
    |=  [=table new=(list [@ schema])]
    ^-  (map @ record)
    |-
    ?~  new  records.table
    ?:  (~(has by records.table) -.i.new)
      !!
    $(new t.new, records.table (~(put by records.table) i.new))
  ::
  ++  delete
    ::  delete any record that matches all selectors
    |=  [=table conds=(list selector)]
    ^-  (map @ record)
    %-  ~(gas by *(map @ record))
    %+  skip  ~(tap by records.table)
    |=  r=[@ record]
    %+  levy  conds
    |=  s=selector
    (s !<(schema !>(r)))
  ::
  ::  nice printing
  ::
  ++  pretty-print
    |=  =table
    %-  ~(rut by records.table)
    |=  r=[@ record]
    !<(schema !>(r))
  --
::
::  rdb engine arms
::
::  run query on database
::
++  run-query
  |*  [=database =query schema=mold]
  ~>  %bout
  =/  tabi  (tab schema)
  ?-    -.query
      %select
    =/  =table  (~(got by tables.database) from.query)
    (select:tabi table conds.query)
  ::
      %project
    =/  =table  (~(got by tables.database) from.query)
    (project:tabi table projector.query)
  ::
      %insert
    %+  ~(jab by tables.database)  into.query
    |=  =table
    %=  table
      records  (insert:tabi table records.query)
    ==
  ::
      %delete
    %+  ~(jab by tables.database)  from.query
    |=  =table
    %=  table
      records  (delete:tabi table conds.query)
    ==
  ==
--