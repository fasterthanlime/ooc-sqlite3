
use sqlite3
import sqlite3/sqlite3

dbPath := "asd.db"

main: func {
    createTable()
    insertInto()
    selectFrom()
    dropTable()
}

createTable: func {
    db := Database new(dbPath)
    stmt := db prepare("create table stuff(asd,zxc);")
    stmt step()
    "#{stmt}" println()
    stmt finalize()
    db close()
}


insertInto: func {
    db := Database new(dbPath)
    stmt := db prepare("insert into stuff values(?, ?);")
    stmt bind(1, 42)
    stmt bind(2, 31)
    stmt step()
    "#{stmt}" println()
    stmt finalize()
}

selectFrom: func {
    db := Database new(dbPath)
    db exec("select * from stuff", |vals|
        "#{vals get("asd") toInt()}" println()
        "#{vals get("zxc") toInt()}" println()
    )
    db close()
}


dropTable: func {
    db := Database new(dbPath)
    stmt := db prepare("drop table stuff;")
    stmt step()
    "#{stmt}" println()
    stmt finalize()
    db close()
}



