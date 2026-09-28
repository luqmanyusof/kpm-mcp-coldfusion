-- =====================================================================
--  Creates the course user `cfapp` inside the XEPDB1 database.
--  Run in DBeaver on the `admin` connection (sys / SYSDBA), Alt+X.
--  day1.md, step 1.5.  LOCAL TRAINING ONLY - cfapp123 is throwaway.
--
--  Re-running gives "ORA-01920: user name 'CFAPP' conflicts" - that just
--  means the user already exists; it is safe to ignore.
-- =====================================================================

CREATE USER cfapp IDENTIFIED BY cfapp123 DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE VIEW TO cfapp;
