use sqlite3
import sqlite3/sqlite3

main: func {
  db := Database new("asd.db")
  db exec("select * from stuff", |vals|
    "#{vals get("asd") toInt()}" println()
    "#{vals get("zxc") toInt()}" println()
  )
  db close()
}

