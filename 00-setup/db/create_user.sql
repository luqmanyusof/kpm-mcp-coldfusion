-- =====================================================================
--  Creates the course user `cfapp` inside the XEPDB1 database.
--  Run ONCE, as SYS (00-setup/SETUP.md, step 4). Safe to run again.
--  LOCAL TRAINING ONLY - cfapp123 is a throwaway password.
-- =====================================================================

SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE

DECLARE
    n NUMBER;
BEGIN
    SELECT COUNT(*) INTO n FROM dba_users WHERE username = 'CFAPP';
    IF n = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER cfapp IDENTIFIED BY cfapp123 DEFAULT TABLESPACE users QUOTA UNLIMITED ON users';
    END IF;
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE VIEW TO cfapp';
END;
/

SELECT 'user cfapp ready' AS result FROM dual;

EXIT
