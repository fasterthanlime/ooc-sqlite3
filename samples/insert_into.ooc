use sqlite3
import sqlite3/sqlite3

main: func {
  db := Database new("asd.db")
  stmt := db prepare("insert into stuff values(?, ?);")
  stmt bind(1, 42)
  stmt bind(2, 31)
  stmt step()
  "#{stmt}" println()
  stmt finalize()
  db close()
}

