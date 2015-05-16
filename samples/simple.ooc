
use sqlite3
import sqlite3
import io/File

dbPath := "simple.db"

main: func {
    File new(dbPath) rm()
    createTable()
    insertInto()
    selectFrom()
    dropTable()
}

createTable: func {
    db := Database new(dbPath)
    stmt := db prepare("create table builds(id int, comment string);")
    stmt step()
    "#{stmt}" println()
    stmt finalize()
    db close()
}


insertInto: func {
    db := Database new(dbPath)
    stmt := db prepare("insert into builds(id, comment) values(?, ?);")
    stmt bind(1, 42)
    stmt bind(2, "please work")
    stmt step()
    "#{stmt}" println()
    stmt finalize()
    "last insert rowID = #{db lastInsertRowId()}" println()
}

selectFrom: func {
    db := Database new(dbPath)
    db exec("select * from builds", |vals|
        "#{vals get("id") toInt()}, #{vals get("comment") toString()}" println()
    )
    db close()
}


dropTable: func {
    db := Database new(dbPath)
    stmt := db prepare("drop table builds;")
    stmt step()
    "#{stmt}" println()
    stmt finalize()
    db close()
}



