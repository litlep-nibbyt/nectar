::
::  relational
::            database
::
|%
+$  database
  $:  owner=term            ::  the creating agent
      editors=(set term)    ::  owner-only by default
      tables=(map term table)
  ==
::
+$  table
  $:  name=term
      schema=(map term column)  ::  term is semantic label
      primary-key=term
      records=(map term record)  ::  set of representations
  ==
::
+$  column
  $:  index=@ud
      key=[? primary=?]
      optional=?  ::  if true, record stores as unit
      =column-type
  ==
::
+$  column-type
  $?  ::  just the basics, can add more atom annotations
      %ud  %ux  %da  %t  %f
      ::  more complex column types
      %list  %set  %map  %blob
  ==
::
+$  record  (map key row)
+$  key  value
+$  row  (list value)
+$  value
  $@  @
  $?  (unit @)
  $%  [%list (list value)]  [%set (set value)]
      [%map (map value value)]  [%blob *]
  ==  ==
::
+$  query
  $%  [%select table=?(term query) where=condition]
      [%project table=?(term query) cols=(set term)]
      [%insert table=?(term query) rows=(list row)]
      [%delete table=?(term query) where=condition]
      [%rename table=?(term query) old=term new=term]
      [%cross-product table=?(term query) with=?(term query)]
      [%table table=term]  ::  to avoid type-loop
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
      [%s gat=$-(value ?)]
      [%atom gat=$-(@ ?)]
      [%unit gat=$-((unit @) ?)]
  ==
--