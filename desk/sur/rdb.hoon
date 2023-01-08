|%
::
::  IDs are default primary keys, starting at 0 and incrementing
::
+$  id  @
+$  primary-key  (pair term iota)
::
++  database
  |$  [id table]
  (map id table)
::
++  table
  |$  [fields primary-key mol records]
  $:  fields=(map term iota)
      primary-key=term
      schema=mold
      records=(map @ record)
  ==
  ::|=  [f=(map term iota) p=(pair term iota) r=(map @ record)]
  ::?.  (~(has by f) p.p)  %.n
  ::?.  =(-.u.k -.q.p)  %.n
  ::=/  fset  (~(del in ~(key by f)) p.p)
  ::%-  ~(all by r)
  ::::  assert each record has and fits all fields
  ::|=  =record
  ::=(fset ~(key by record))
::
+$  record  *
::
::
::
+$  selector  $-(* ?)
+$  query
  $%  [%select from=id conds=(list selector)]
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