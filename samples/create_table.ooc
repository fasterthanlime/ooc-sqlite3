use sqlite3
import sqlite3/sqlite3

main: func {
  db := Database new("asd.db")
  stmt := db prepare("create table stuff(asd,zxc);")
  stmt step()
  "#{stmt}" println()
  stmt finalize()
  db close()
}

