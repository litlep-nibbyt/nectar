|%
::
::  iota
::
+$  iota
  $~  [%n ~]
  $@  @tas
  $%  ::  atom types
      [%ub @ub]  [%uc @uc]  [%ud @ud]  [%ui @ui]
      [%ux @ux]  [%uv @uv]  [%uw @uw]
      [%sb @sb]  [%sc @sc]  [%sd @sd]  [%si @si]
      [%sx @sx]  [%sv @sv]  [%sw @sw]
      [%da @da]  [%dr @dr]
      [%f ?]     [%n ~]
      [%if @if]  [%is @is]
      [%t @t]    [%ta @ta]  ::  @tas
      [%p @p]    [%q @q]
      [%rs @rs]  [%rd @rd]  [%rh @rh]  [%rq @rq]
      ::  advanced types
      [%list t=iota]
      [%cell p=iota q=iota]
      [%set t=iota]
      [%map key=iota val=iota]
      [%blob *]
  ==
::
::  an agent creates a database and maintains control
::
+$  database
  $:  owner=term  ::  the creating agent
      editors=(set term)  ::  owner-only by default
      tables=(map @ table)  ::  @ can be @t name or just integer
  ==
::
+$  table
  $:  schema=()
  ==
--