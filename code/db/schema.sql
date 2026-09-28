-- =====================================================================
--  cf-learn-cfml - Oracle schema (Oracle 21c XE, also valid on 19c)
--
--  Run / reset any time (Oracle XE running, user cfapp created by create_user.sql):
--    cd <course folder>\db
--    sqlplus -s "cfapp/cfapp123@//localhost:1521/XEPDB1" "@schema.sql"
--
--  Two tables:
--    pelajar - simple 3-column table (id, name, email) used by the
--              BASICS module (read) and the API module (learner CRUD).
--    murid   - full student record used by the pre-built CRUD module.
--
--  Oracle vs MySQL, for readers of the old version:
--    AUTO_INCREMENT -> a SEQUENCE used as the column DEFAULT
--    ENUM(...)      -> VARCHAR2 + CHECK constraint
--    TINYINT        -> NUMBER(3)
--    ON UPDATE      -> a BEFORE UPDATE trigger
-- =====================================================================

SET DEFINE OFF
SET FEEDBACK OFF

-- ---- Drop old objects (ignore "does not exist") ----------------------
BEGIN
    FOR o IN (SELECT 'TABLE' t, table_name n FROM user_tables
               WHERE table_name IN ('PELAJAR', 'MURID')
              UNION ALL
              SELECT 'SEQUENCE', sequence_name FROM user_sequences
               WHERE sequence_name IN ('PELAJAR_SEQ', 'MURID_SEQ')) LOOP
        EXECUTE IMMEDIATE 'DROP ' || o.t || ' ' || o.n || CASE o.t WHEN 'TABLE' THEN ' PURGE' END;
    END LOOP;
END;
/

-- ---- Simple table (basics + api) ------------------------------------
CREATE SEQUENCE pelajar_seq START WITH 1 NOCACHE;

CREATE TABLE pelajar (
    id    NUMBER(10)     DEFAULT pelajar_seq.NEXTVAL NOT NULL,
    name  VARCHAR2(100)  NOT NULL,
    email VARCHAR2(150)  NOT NULL,
    CONSTRAINT pk_pelajar PRIMARY KEY (id)
);

INSERT INTO pelajar (name, email) VALUES ('Ahmad Danish', 'ahmad.danish@example.com');
INSERT INTO pelajar (name, email) VALUES ('Nur Aisyah',   'nur.aisyah@example.com');
INSERT INTO pelajar (name, email) VALUES ('Tan Wei Jie',  'weijie.tan@example.com');
INSERT INTO pelajar (name, email) VALUES ('Priya Suresh', 'priya.suresh@example.com');
INSERT INTO pelajar (name, email) VALUES ('Lim Mei Ling', 'meiling.lim@example.com');

-- ---- Full table (crud module) ---------------------------------------
CREATE SEQUENCE murid_seq START WITH 1 NOCACHE;

CREATE TABLE murid (
    id                     NUMBER(10)     DEFAULT murid_seq.NEXTVAL NOT NULL,
    nama                   VARCHAR2(100)  NOT NULL,
    no_kp                  VARCHAR2(14)   NOT NULL,              -- IC, cth: 090312-10-5217
    jantina                VARCHAR2(10)   NOT NULL,
    tingkatan              NUMBER(1)      NOT NULL,              -- 1..5
    kelas                  VARCHAR2(30)   NOT NULL,
    tarikh_lahir           DATE           NOT NULL,
    bangsa                 VARCHAR2(10)   DEFAULT 'Melayu' NOT NULL,
    agama                  VARCHAR2(30)   NOT NULL,
    pendapatan_isi_rumah   NUMBER(10,2)   DEFAULT 0 NOT NULL,
    bilangan_adik_beradik  NUMBER(3)      DEFAULT 0 NOT NULL,
    created_at             TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at             TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_murid         PRIMARY KEY (id),
    CONSTRAINT uq_murid_no_kp   UNIQUE (no_kp),
    CONSTRAINT ck_murid_jantina CHECK (jantina IN ('Lelaki', 'Perempuan')),
    CONSTRAINT ck_murid_bangsa  CHECK (bangsa IN ('Melayu', 'Cina', 'India', 'Lain-lain')),
    CONSTRAINT ck_murid_ting    CHECK (tingkatan BETWEEN 1 AND 5)
);

CREATE INDEX idx_murid_tingkatan ON murid (tingkatan);
CREATE INDEX idx_murid_nama      ON murid (nama);

-- Keeps updated_at current (MySQL did this with ON UPDATE CURRENT_TIMESTAMP).
CREATE OR REPLACE TRIGGER trg_murid_updated
BEFORE UPDATE ON murid
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Ahmad Danish bin Rosli',   '090312-10-5217', 'Lelaki',    5, 'Bestari', DATE '2009-03-12', 'Melayu', 'Islam',     3500.00, 2);
INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Nur Aisyah binti Kamal',   '100725-14-6320', 'Perempuan', 4, 'Cerdik',  DATE '2010-07-25', 'Melayu', 'Islam',     8200.00, 4);
INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Tan Wei Jie',              '111103-07-5419', 'Lelaki',    3, 'Bestari', DATE '2011-11-03', 'Cina',   'Buddha',   12000.00, 1);
INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Priya a/p Suresh',         '120518-01-6028', 'Perempuan', 2, 'Amanah',  DATE '2012-05-18', 'India',  'Hindu',     2800.00, 3);
INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Lim Mei Ling',             '130930-08-6144', 'Perempuan', 1, 'Cerdik',  DATE '2013-09-30', 'Cina',   'Kristian',  5400.00, 2);
INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
VALUES ('Muhammad Haziq bin Azman', '100214-10-5133', 'Lelaki',    4, 'Bestari', DATE '2010-02-14', 'Melayu', 'Islam',     6700.00, 5);

COMMIT;

SELECT 'pelajar rows: ' || COUNT(*) AS result FROM pelajar;
SELECT 'murid rows: '   || COUNT(*) AS result FROM murid;

EXIT
