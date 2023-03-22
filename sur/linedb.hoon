|%
::  snapshots are full document sets with all lines
::  structural sharing makes this efficient?
::
::  a branch is an ordered history of snapshots.
::  make a new branch by selecting an existing one to go off
::
::  to add a commit to a branch, simply call +add-commit:branch
::  with your files
::
+$  index      @ud
+$  file       wain
+$  file-name  path
+$  diff       (urge:clay cord)
+$  snapshot   (map file-name file)
+$  commit
  $:  author=ship
      =snapshot
      diffs=(map file-name diff)
  ==
::
++  snap-on  ((on index commit) lth)
--
