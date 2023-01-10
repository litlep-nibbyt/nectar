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
  $%  [%l (list value)]       [%s (set value)]
      [%m (map value value)]  [%b *]
  ==  ==
::
+$  query
  $%  [%select table=?(term query) where=condition]
      [%project table=?(term query) cols=(set term)]
      [%insert table=?(term query) rows=(list row)]
      [%delete table=?(term query) where=condition]
      [%rename table=?(term query) old=term new=term]
      [%cross-product table=?(term query) with=?(term query)]
      [%union table=?(term query) with=?(term query)]
      [%difference table=?(term query) with=?(term query)]
      [%theta-join table=?(term query) with=?(term query) where=condition]
      [%table table=term]  ::  to avoid type-loop
  ==
::
+$  condition
  $~  [%n ~]
  $%  [%n ~]
      [%s c=term s=selector]
      [%d c1=term c2=term c=comparator]
      [%and a=condition b=condition]
      [%or a=condition b=condition]
  ==
::
+$  selector
  $%  [%eq @]   [%not @]
      [%gte @]  [%lte @]
      [%gth @]  [%lth @]
      [%custom gat=$-(value ?)]
      [%atom gat=$-(@ ?)]
      [%unit gat=$-((unit @) ?)]
  ==
::
+$  comparator
  $%  %eq   %not
      %gte  %lte
      %gth  %lth
  ==
--