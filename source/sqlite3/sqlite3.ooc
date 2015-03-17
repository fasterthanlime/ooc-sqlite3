include sqlite3

import structs/HashMap

// Database

SqliteStruct: cover from sqlite3*

Database: cover from SqliteStruct {
  _open: static extern(sqlite3_open) func (CString, Database*) -> Int
  new: static func (file: String) -> This {
    this: This
    This _open(file toCString(), this&)
    return this
  }
  initialize: extern(sqlite3_initialize) static func -> Int
  close: extern(sqlite3_close) func -> Int

  errcode: extern(sqlite3_errcode) func -> Int
  _errmsg: extern(sqlite3_errmsg) func -> CString
  errmsg: func -> String { _errmsg() toString() }

  _prepare: extern(sqlite3_prepare_v2) func (CString, Int, Statement*, const CString*) -> Int
  prepare: func (query: String) -> Statement {
    res: Statement
    this _prepare(query toCString(), -1, res&, null)
    return res
  }

  exec: func (query: String, callback: Func (HashMap<String, Value>)) -> Int{
    stmt := this prepare(query)
    res := stmt step()
    while (res == Sqlite3Code row){
      h := stmt toHashMap()
      callback(h)
      res = stmt step()
    }
    stmt finalize()
    return res
  }
}

// Values

SqliteValueStruct: cover from sqlite3_value*

Value: cover from SqliteValueStruct {
  toInt: extern(sqlite3_value_int) func -> Int
  toInt64: extern(sqlite3_value_int64) func -> Int64
  toDouble: extern(sqlite3_value_double) func -> Double
  toCString: extern(sqlite3_value_text) func -> CString
  toString: func -> String { toCString() toString() }
  toBlob: extern(sqlite3_value_blob) func -> Pointer
}

// Prepared statements

SqliteStmtStruct: cover from sqlite3_stmt*

Statement: cover from SqliteStmtStruct {
  step: extern(sqlite3_step) func -> Int
  finalize: extern(sqlite3_finalize) func -> Int
  reset: extern(sqlite3_reset) func -> Int

  new: static func -> This {
    this := gc_malloc(This size) as This
    return this
  }

  columnCount: extern(sqlite3_column_count) func -> Int
  intColumn: extern(sqlite3_column_int) func (Int) -> Int
  int64Column: extern(sqlite3_column_int64) func (Int) -> Int64
  textColumn: extern(sqlite3_column_text) func (Int) -> String
  blobColumn: extern(sqlite3_column_blob) func (Int) -> Pointer
  doubleColumn: extern(sqlite3_column_blob) func (Int) -> Double
  valueColumn: extern(sqlite3_column_value) func (Int) -> Value

  bindParameterCount: extern(sqlite3_bind_parameter_count) func -> Int
  bindInt: extern(sqlite3_bind_int) func (Int, Int) -> Int
  bindInt64: extern(sqlite3_bind_int64) func (Int, Int64) -> Int
  bindNull: extern(sqlite3_bind_null) func (Int) -> Int
  bindDouble: extern(sqlite3_bind_double) func (Int, Double) -> Int
  _bind_text: extern(sqlite3_bind_text) func (Int, CString, Int, Pointer) -> Int
  bindText: func (id: Int, text: String) -> Int {
    return this _bind_text(id, text toCString(), -1, null)
  }
  _bind_blob: extern(sqlite3_bind_blob) func (Int, Pointer, Int, Pointer) -> Int
  bindBlob: func (id: Int, data: Pointer, size: Int) -> Int {
    return this _bind_blob(id, data, size, null)
  }
  bindValue: extern(sqlite3_bind_value) func (Int, Value) -> Int

  bind: func <T> (id: Int, val: T) -> Int {
    match val {
        case i: Int    => this bindInt(id, i)
        case I: Int64  => this bindInt64(id, I)
        case d: Double => this bindDouble(id, d)
        case s: String => this bindText(id, s)
        case           => Sqlite3Code misuse
    }
  }

  _columnName: extern(sqlite3_column_name) func (Int) -> CString
  columnName: func (i: Int) -> String { _columnName(i) toString() }

  _columnDb: extern(sqlite3_column_database_name) func (Int) -> CString
  columnDb: func (i: Int) -> String { _columnDb(i) toString() }

  _columnTable: extern(sqlite3_column_table_name) func (Int) -> CString
  columnTable: func (i: Int) -> String { _columnTable(i) toString() }

  _sql: extern(sqlite3_sql) func -> CString
  toString: func -> String {
      s := _sql()
      s toString()
  }

  toHashMap: func -> HashMap<String, Value> {
    map := HashMap<String, Value> new()
    n := this columnCount()
    for (i in 0..n){
      name := this columnName(i)
      val := this valueColumn(i)
      map put(name, val)
    }
    return map
  }
}

// Return codes

Sqlite3Code: enum from Int {
  ok:          extern(SQLITE_OK),          /* Successful result */
/* beginning-of-error-codes */
  error:       extern(SQLITE_ERROR),       /* SQL error or missing database */
  _internal:   extern(SQLITE_INTERNAL),    /* internal logic error in SQLite */
  perm:        extern(SQLITE_PERM),        /* Access permission denied */
  abort:       extern(SQLITE_ABORT),       /* Callback routine requested an abort */
  busy:        extern(SQLITE_BUSY),        /* The database file is locked */
  locked:      extern(SQLITE_LOCKED),      /* A table in the database is locked */
  nomem:       extern(SQLITE_NOMEM),       /* A malloc(), failed */
  readonly:    extern(SQLITE_READONLY),    /* Attempt to write a readonly database */
  interrupt:   extern(SQLITE_INTERRUPT),   /* Operation terminated by sqlite3_interrupt(),*/
  ioerr:       extern(SQLITE_IOERR),       /* Some kind of disk I/O error occurred */
  corrupt:     extern(SQLITE_CORRUPT),     /* The database disk image is malformed */
  notfound:    extern(SQLITE_NOTFOUND),    /* NOT USED. Table or record not found */
  full:        extern(SQLITE_FULL),        /* Insertion failed because database is full */
  cantopen:    extern(SQLITE_CANTOPEN),    /* Unable to open the database file */
  protocol:    extern(SQLITE_PROTOCOL),    /* NOT USED. Database lock protocol error */
  empty:       extern(SQLITE_EMPTY),       /* Database is empty */
  schema:      extern(SQLITE_SCHEMA),      /* The database schema changed */
  toobig:      extern(SQLITE_TOOBIG),      /* String or BLOB exceeds size limit */
  constraint:  extern(SQLITE_CONSTRAINT),  /* Abort due to constraint violation */
  mismatch:    extern(SQLITE_MISMATCH),    /* Data type mismatch */
  misuse:      extern(SQLITE_MISUSE),      /* Library used incorrectly */
  nolfs:       extern(SQLITE_NOLFS),       /* Uses OS features not supported on host */
  auth:        extern(SQLITE_AUTH),        /* Authorization denied */
  format:      extern(SQLITE_FORMAT),      /* Auxiliary database format error */
  range:       extern(SQLITE_RANGE),       /* 2nd parameter to sqlite3_bind out of range */
  notadb:      extern(SQLITE_NOTADB),      /* File opened that is not a database file */
  row:         extern(SQLITE_ROW),         /* sqlite3_step(), has another row ready */
  done:        extern(SQLITE_DONE)         /* sqlite3_step(), has finished executing */
}

