|%
::  snapshots are full document sets with all lines
::  structural sharing makes this efficient
::
::  a branch is an ordered history of snapshots
::
::  make a new branch by selecting an existing one to go off
::  can make a branch with no parent that starts empty?
::
::  to add a commit to a branch, simply
::  - apply a (list diff) to the current snapshot
::  - attach the commit plus the new snapshot at +(index)
::  - update head of the branch
::
::  to see contents of repo in branch at commit:
::  - get snapshot at index of commit in branch
::
::  to see changes at commit:
::  - look at diff paired with snapshot at index
::
::  to build a commit, apply each diff in list
::  to snapshot at head index of branch.
::
+$  line      cord
+$  line-num  @ud
+$  index     @ud
+$  doc       ((mop line-num line) lth)
+$  doc-name  path
::
+$  diff  [=doc-name =line-num =line]
::
+$  snapshot     (map doc-name doc)
::
+$  commit
  $:  author=ship
      =snapshot
      diffs=(list diff)
  ==
::
+$  branch
  $:  snaps=((mop index commit) lth)
      head=index
  ==
::
++  doc-on    ((on line-num line) lth)
++  snap-on  ((on index commit) lth)
--