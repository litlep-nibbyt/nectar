/-  *rdb
|%
::
::  test data
::
+$  my-mold
  [id=@ name=@t score=@ud]
++  my-table
  =/  fields
    %-  ~(gas by *(map term iota))
    ~[[%id [%ud *@ud]] [%name [%t *@t]] [%score [%ud *@ud]]]
  =/  prim  %id
  =/  records
    %-  ~(gas by *(map @ record))
    ^-  (list [@ (map term *)])
    :~  [0 (malt `(list [term *])`~[[%name 'nick'] [%score 100]])]
        [1 (malt `(list [term *])`~[[%name 'drew'] [%score 700]])]
        [2 (malt `(list [term *])`~[[%name 'will'] [%score 1.000]])]
    ==
  [fields prim my-mold records]
::
::  table engine
::
++  tab
  |*  [id=@ schema=mold]
  =>  |%
      +$  recs  (tree (pair kee (pair hash val)))
      --
  |%


  --


::
::  ++  my-db
::    (~(gas by *(database @ )
::
::  ++  my-selector-1
::    ^-  selector
::    |=  [id =record]
::    ^-  ?
::    ?~  s=(~(get by record) %score)  %.n
::    (gte ;;(@ud u.s) 500)
::  ::
::  ++  my-selector-2
::    ^-  selector
::    |=  [id =record]
::    ^-  ?
::    ?~  n=(~(get by record) %name)  %.n
::    !=(;;(@t u.n) 'will')
::  ::
::  ++  my-query
::    ^-  query
::    [%select from=0 ~[my-selector-1 my-selector-2]]
::
::  rdb engine arms
::
::
::  apply schema to table for a better pretty-print
::
::  ++  print-table
::    |=  =table
::    !!
::
::  run query on database
::
::  ++  run-query
::    |=  =query
::    ?-    -.query
::        %select
::      ::  perform all selectors on each record in table
::      :^    fields.table
::          primary-key.table
::        mol.table
::      %-  ~(gas by *(map id record))
::      %+  skim  ~(tap by records.table)
::      |=  r=[id record]
::      %+  levy  conds.query
::      |=  s=selector
::      (s !<(mol.table !>(r)))
::    ==
--