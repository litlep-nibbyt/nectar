/-  *rdb
|%
++  table
  |*  [=table-spec types=(map term mold)]
  =>  |%
      +$  schema
        (map term column-type)
      +$  column-type
        $:  spot=@
            typ=term
        ==
      +$  record

      --
--