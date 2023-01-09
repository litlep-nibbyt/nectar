::
::  relational
::            database
::
|%
+$  database
  $:  owner=term            ::  the creating agent
      editors=(set term)    ::  owner-only by default
      tables=(map @ table)  ::  @ can be @t name or just integer
  ==
::
+$  table
  $:  schema=(map term column)  ::  term is semantic label
      primary-key=term
      records=(map term record)  ::  set of representations
  ==
::
+$  record  (map * (list *))  ::  get types from schema
::
+$  column
  $:  index=@ud
      key=[? primary=?]
      optional=?  ::  if true, record stores as unit
      =column-type
  ==
::
+$  column-type
  $%  ::  just the basics, can add more atom annotations
      [%atom %ud]  [%atom %ux]  [%atom %da]  [%atom %t]  [%atom %f]
      ::  more complex column types = bring your own subtypes
      [%noun %list]  [%noun %map]  [%noun %blob]
  ==
::
+$  query
  $%  [%select table=@ where=condition]
  ==
::
+$  condition
  $~  [%n ~]
  $%  [%n ~]
      ::  [%and condition condition]
      ::  [%or condition condition]
      [term selector]
  ==
::
+$  selector
  $%  [%gte @]  [%lte @]  [%other @]
  ==
::
::  +$  query
::    $%  [%select from=id conds=(list selector)]
::        [%project from=id =projector]
::        [%insert into=id records=(list [@ record])]
::        [%delete from=id conds=(list selector)]
::    ==
--