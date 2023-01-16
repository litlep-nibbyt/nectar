::
::  relational
::            database
::
|%
+$  table
  $:  name=term
      owner=term          ::  agent name
      editors=(set term)  ::  owner-only by default
      =schema
      primary-key=(list term)
      =indices
      records=(map (list term) record)
  ==
::
+$  schema   (map term column-type)  ::  term is semantic label
+$  indices  (map (list term) key-type)
::
+$  key-type
  $:  cols=(list term)  ::  which columns included in key (at list position)
      primary=?         ::  only one primary key per table (must be unique)
      unique=?          ::  if not unique, store rows in list under key
      clustered=(unit comparator)  ::  ordering function -- if clustered,
  ==                               ::  must be *singular* column in key.
::
+$  column-type
  $:  spot=@      ::  where column sits in row
      optional=?  ::  if optional, value is unit
      $=  typ
      $?  ::  just the basics, can add more atom annotations
          %ud  %ux  %da  %t  %f
          ::  more complex column types
          %list  %set  %map  %blob
      ==
  ==
::
+$  record
  %+  each
    (tree [key row])       ::  unique key
  (tree [key (list row)])  ::  non-unique key
::
+$  key  (list value)
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
      [%d c1=term c=comparator c2=term]
      [%and a=condition b=condition]
      [%or a=condition b=condition]
  ==
::
+$  selector
  $%  [%eq @]   [%not @]
      [%gte @]  [%lte @]
      [%gth @]  [%lth @]
      [%atom gat=$-(@ ?)]
      [%unit gat=$-((unit @) ?)]
      [%custom gat=$-(value ?)]
  ==
::
+$  comparator
  $%  %eq   %not
      %gte  %lte
      %gth  %lth
      [%atom gat=$-([@ @] ?)]
      [%unit gat=$-([(unit @) (unit @)] ?)]
      [%custom gat=$-([value value] ?)]
  ==
--