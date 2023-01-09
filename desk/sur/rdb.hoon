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
+$  column
  $:  index=@ud
      key=[? primary=?]
      optional=?  ::  if true, record stores as unit (TODO)
      =column-type
  ==
::
+$  column-type
  $?  ::  just the basics, can add more atom annotations
      %ud  %ux  %da  %t  %f
      ::  more complex column types = bring your own subtypes
      [%noun %list]  [%noun %map]  [%noun %blob]
  ==
::
+$  record  (map key row)
+$  key  value
+$  row  (list value)
+$  value
  $@  @
  $?  (unit @)  [%list *]  [%map *]  [%blob *]
  ==
::
+$  query
  $%  [%select table=?(@ query) where=condition]
      [%project table=?(@ query) cols=(set term)]
      [%insert table=?(@ query) rows=(list row)]
      [%delete table=?(@ query) where=condition]
      [%table table=@]  ::  to avoid type-loop
  ==
::
+$  condition
  $~  [%n ~]
  $%  [%n ~]
      [%s t=term s=selector]
      [%and a=condition b=condition]
      [%or a=condition b=condition]
  ==
::
+$  selector
  $%  [%eq @]   [%not @]
      [%gte @]  [%lte @]
      [%atom gat=$-(@ ?)]
      [%unit gat=$-((unit @) ?)]
      [%custom gat=$-(* ?)]
  ==
--