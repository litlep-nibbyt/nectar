|%
::
::  IDs are default primary keys, starting at 0 and incrementing
::
+$  id  @
+$  primary-key  (pair term iota)
::
+$  database
  (map id table)
::
+$  table
  $:  fields=(map term iota)
      primary-key=term
      records=(map @ record)
  ==
::
++  schema
  |$  [mold]  mold
::
+$  record  *
::
++  selector
  $_  ^|  |=(* *?)
::
++  projector
  $_  ^|  |=(* **)
::
+$  query
  $%  [%select from=id conds=(list selector)]
      [%project from=id =projector]
  ==
::
::  iota
::  TODO expand for more data types: certain cells, sets, lists, blobs?
::
+$  iota
  $~  [%n ~]
  $@  @tas
  $%  [%ub @ub]  [%uc @uc]  [%ud @ud]  [%ui @ui]
      [%ux @ux]  [%uv @uv]  [%uw @uw]
      [%sb @sb]  [%sc @sc]  [%sd @sd]  [%si @si]
      [%sx @sx]  [%sv @sv]  [%sw @sw]
      [%da @da]  [%dr @dr]
      [%f ?]     [%n ~]
      [%if @if]  [%is @is]
      [%t @t]    [%ta @ta]  ::  @tas
      [%p @p]    [%q @q]
      [%rs @rs]  [%rd @rd]  [%rh @rh]  [%rq @rq]
  ==
--