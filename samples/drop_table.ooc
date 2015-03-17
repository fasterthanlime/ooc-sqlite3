use sqlite3
import sqlite3/sqlite3

main: func {
  db := Database new("asd.db")
  stmt := db prepare("drop table stuff;")
  stmt step()
  "#{stmt}" println()
  stmt finalize()
  db close()
}


