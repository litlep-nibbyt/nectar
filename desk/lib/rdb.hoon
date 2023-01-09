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
  [fields prim records]
::
++  my-db
  (malt ~[[0 my-table]])
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
  [%select from=0 ~[my-selector-1]]
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
  --
::
::  rdb engine arms
::
::  run query on database
::
++  run-query
  |*  [=database =query schema=mold]
  =/  tabi  (tab schema)
  ?-    -.query
      %select
    =/  =table  (~(got by database) from.query)
    (select:tabi table conds.query)
  ::
      %project
    =/  =table  (~(got by database) from.query)
    (project:tabi table projector.query)
  ==
--