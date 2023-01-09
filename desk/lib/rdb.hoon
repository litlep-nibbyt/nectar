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
      :~  [%id [0 [& &] | [%atom %ud]]]
          [%name [1 [| |] | [%atom %t]]]
          [%score [2 [| |] & [%atom %ud]]]
      ==
    primary-key=%id
  ::  one index, so one record
  %-  ~(gas by *(map term record))
  :_  ~
  :-  %id
  ^-  record
  %-  ~(gas by *(map * (list *)))
  :~  [0 ~[0 'nick' 100]]
      [1 ~[1 'drew' 300]]
      [2 ~[2 'will' 700]]
      [3 ~[3 'tobias' 1.000]]
      [4 ~[4 'christian' 1.500]]
      [5 ~[5 'hocwyn' 1.200]]
  ==
::
++  my-query
  ^-  query
  [%select table='my-table' where=[%score %gte 500]]
::
++  run-query
  |=  [db=database q=query]
  ?-    -.q
      %select
    =/  =table  (~(got by tables.db) table.q)
    ::  choose which record to use (optimization)
    =/  rec=record  (~(got by records.table) primary-key.table)
    ?+    -.where.q
        ::  term: apply selector on that col
        =/  =column  (~(got by schema.table) -.where.q)
        ~&  >>  column
        %-  ~(gas by *record)
        %+  skim  ~(tap by rec)
        |=  [key=* val=(list *)]
        %+  apply-selector  +.where.q
        ;;(@ (snag index.column val))
    ::
        %n
      ::  no where clause means get everything
      !!
    ==
  ==
::
++  apply-selector
  |=  [=selector val=@]
  ^-  ?
  ?+  -.selector  !!
    %gte  (gte val +.selector)
    %lte  (lte val +.selector)
  ==
::
:: ++  column-mold
::   |=  =column
::   ?:  optional.column
::     (unit $(optional.column %.n))
::   ?+  column-type.column  !!
::     [%atom %ud]  @ud
::     [%atom %ux]  @ux
::   ==
--