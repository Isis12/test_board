-- 회원테이블
CREATE TABLE MEMBER(
    M_ID        NVARCHAR2(20)   NOT NULL,
    M_PW        NVARCHAR2(100)  NOT NULL,
    M_NAME      NVARCHAR2(10)   NOT NULL,
    M_BIRTH     NVARCHAR2(8)    NOT NULL,
    M_PHONE     NVARCHAR2(11)   NOT NULL,
    M_ADDR_NUM  NVARCHAR2(5)    NOT NULL,
    M_ADDR      NVARCHAR2(100)  NOT NULL,
    M_ADDR_DET  NVARCHAR2(50)   NULL,
    M_POINT     NVARCHAR2(13)   DEFAULT '0' NOT NULL,
    M_GCODE     NCHAR(1)        DEFAULT 'A' NOT NULL,
    M_DATE      DATE            DEFAULT SYSDATE NOT NULL,
    DEL_YN      VARCHAR(1)      DEFAULT 'N' NOT NULL,
    CONSTRAINT  M_ID_PK PRIMARY KEY (M_ID)
);

-- 회원조회
SELECT * FROM MEMBER;

-- 회원등급
CREATE TABLE GRADE(
    G_CODE          NCHAR(1)        NOT NULL,
    G_NAME          NVARCHAR2(10)   NOT NULL,
    G_LOWPOINT      NUMBER          NOT NULL,
    G_HIGHPOINT     NUMBER          NOT NULL
);

-- 회원등급 더미데이터
INSERT INTO GRADE VALUES('A', '브론즈', 0, 10);
INSERT INTO GRADE VALUES('B', '실버', 11, 20);
INSERT INTO GRADE VALUES('C', '골드', 21, 30);
INSERT INTO GRADE VALUES('G', '관리자', 99, 100);

--등급조회
SELECT * FROM GRADE;

/* 게시판 기본정보
B_TYPE = S: 비밀글 & A: 공지사항 & C: 일반글
*/
-- 게시판테이블
CREATE TABLE BOARD(
    B_NUM       INT             NOT NULL,
    B_TITLE     NVARCHAR2(50)   NOT NULL,
    B_CONTENTS  NCLOB           NOT NULL,
    B_WRITER    NVARCHAR2(20)   NOT NULL,
    B_VIEWS     NUMBER          DEFAULT '0' NOT NULL,
    B_TYPE      VARCHAR(1)      DEFAULT 'C' NOT NULL, /* S:占쏙옙閨占�, A:占쏙옙占쏙옙占쏙옙占쏙옙*/
    B_PW        NVARCHAR2(10),
    B_DATE      DATE            DEFAULT SYSDATE NOT NULL,
    DEL_YN      VARCHAR(1)      DEFAULT 'N' NOT NULL,
    CONSTRAINT  PK_B_NUM    PRIMARY KEY(B_NUM),
    CONSTRAINT  FK_B_WRITER FOREIGN KEY(B_WRITER) REFERENCES MEMBER(M_ID)
);

-- 게시판 시퀀스
CREATE SEQUENCE B_SEQ;

-- 게시판 파일 테이블
CREATE TABLE BOARD_FILE(
    BF_NUM          INT             NOT NULL,
    BF_BNUM         INT             NOT NULL,
    BF_ORIGFILENAME NVARCHAR2(100)  NOT NULL,
    BF_SYSFILENAME  NVARCHAR2(100)  NOT NULL,
    CONSTRAINT  PK_BF_NUM   PRIMARY KEY(BF_NUM),
    CONSTRAINT  FK_BF_BNUM  FOREIGN KEY(BF_BNUM) REFERENCES BOARD(B_NUM)
);

-- 게시판 파일 시퀀스
CREATE SEQUENCE BF_SEQ;

SELECT * FROM BOARD_FILE;


-- 게시판 댓글 테이블
CREATE TABLE REPLY(
    R_NUM       INT             NOT NULL,
    R_BNUM      INT             NOT NULL,
    R_CONTENTS  NVARCHAR2(50)   NOT NULL,
    R_ID        NVARCHAR2(20)   NOT NULL,
    R_DATE      DATE            DEFAULT SYSDATE NOT NULL,
    DEL_YN      VARCHAR(1)      DEFAULT 'N' NOT NULL,
    CONSTRAINT  PK_R_NUM    PRIMARY KEY(R_NUM),
    CONSTRAINT  FK_R_BNUM   FOREIGN KEY(R_BNUM) REFERENCES BOARD(B_NUM)
    --CONSTRAINT  FK_R_ID     FOREIGN KEY(R_ID) REFERENCES MEMBER(M_ID)
);


-- 댓글 시퀀스
CREATE SEQUENCE R_SEQ;

-- 게시판 댓글 조회
SELECT * FROM REPLY;

COMMIT;


--====== VIEW 생성 =======

-- 회원정보 조회뷰
CREATE OR REPLACE VIEW MINFO AS
SELECT MEMBER.M_ID, MEMBER.M_NAME, MEMBER.M_POINT, GRADE.G_NAME
  FROM MEMBER JOIN GRADE
    ON MEMBER.M_POINT BETWEEN GRADE.G_LOWPOINT AND GRADE.G_HIGHPOINT;

SELECT * FROM MINFO;

SELECT * FROM MEMBER;
SELECT * FROM GRADE;

-- 회원정보(관리자) 조회뷰
CREATE OR REPLACE VIEW MLIST AS
SELECT ROWNUM RONUM, MINFO.*
  FROM (SELECT MEMBER.M_ID, MEMBER.M_NAME, MEMBER.M_DATE, MEMBER.M_GCODE, GRADE.G_NAME, MEMBER.DEL_YN
          FROM MEMBER JOIN GRADE
            ON MEMBER.M_GCODE = GRADE.G_CODE
         ORDER BY MEMBER.M_DATE DESC) MINFO;
         

-- 회원정보(관리자)상세보기 조회 뷰
CREATE OR REPLACE VIEW MEMDETINFO AS 
SELECT ROWNUM RONUM, MINFO.*
  FROM (SELECT MEMBER.M_ID, MEMBER.M_PW, MEMBER.M_NAME, MEMBER.M_BIRTH, MEMBER.M_PHONE, MEMBER.M_ADDR, MEMBER.M_ADDR_NUM, MEMBER.M_ADDR_DET,  MEMBER.M_POINT, MEMBER.M_DATE, GRADE.G_NAME, MEMBER.DEL_YN
          FROM MEMBER JOIN GRADE
            ON MEMBER.M_GCODE = GRADE.G_CODE
         ORDER BY MEMBER.M_DATE DESC) MINFO;    
  
SELECT * FROM MEMDETINFO;


-- 게시판정보 조회뷰
CREATE OR REPLACE VIEW BLIST AS
SELECT ROWNUM RONUM,MINFO.*
  FROM (SELECT BOARD.B_NUM, BOARD.B_TITLE, BOARD.B_CONTENTS, BOARD.B_WRITER, MEMBER.M_NAME, BOARD.B_DATE
          FROM BOARD JOIN MEMBER
            ON BOARD.B_WRITER = MEMBER.M_ID
         ORDER BY BOARD.B_DATE DESC) MINFO;
         
SELECT * FROM BLIST;

-- 게시판정보(2) 조회뷰
CREATE OR REPLACE VIEW BLIST_1 AS
SELECT ROWNUM RONUM1, BLIST.*
  FROM BLIST;
  
SELECT * FROM BLIST_1

  
-- 댓글정보 조회뷰
CREATE OR REPLACE VIEW RLIST AS 
SELECT *
  FROM REPLY
 ORDER BY R_DATE DESC;


 
