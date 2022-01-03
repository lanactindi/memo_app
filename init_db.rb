# frozen_string_literal: true

require 'pg'

conn = PG.connect(dbname: 'postgres')
conn.exec("CREATE TABLE memos(
    id VARCHAR,
    title VARCHAR NOT NULL ,
    content VARCHAR NOT NULL)")
