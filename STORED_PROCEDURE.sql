-- SQL프로그래밍
-- > SQL은 다른 프로그래밍 언어와는 많이 다르지만 MySQL에서 프로그래밍 기능이 필요하다면
-- > 스토어드 프로시저를 사용할 수 있음
-- > SQL 프로그래밍은 기본적으로 스토어드 프로시저 안에서 만들어야함

-- 스토어드 프로시저의 구조
-- > 스토어드 프로시저는 delimiter $$ ~ end $$ 안에 작성하고 call로 호출
DELIMITER $$
CREATE PROCEDURE 스토어드_프로시저_이름()
BEGIN
	SQL 프로그래밍 코딩 영역
END $$ -- 스토어드 프로시저 종료
DELIMITER ; -- 종료문자를 다시 세미콜론으로 변경
CALL 스토어드_프로시저_이름(); -- 스토어드 프로시저 실행

-- DELIMETER : 구문 문자를 정의하는 기능
-- > 프로시저 내에서 문장을 구분하기 어렵기 때문에 구문 문자로 정의

-- IF 문
-- > 조건문으로 가장 많이 사용되는 프로그래밍 문법

-- IF문의 기본 형식
-- > 조건식이 참이라면 'SQL문장들'을, 실행하고, 그렇지 않으면 넘어감
IF <조건식> THEN
	SQL 문장들
END IF;

-- 위의 'SQL 문장들'이 한 문장이라면 그문장만 써도 되지만
-- 두문장 이상이 처리되어야 한다면 BEGIN ~ END로 묶어야 함
-- 관습적으로는 한 문장이더라도 나중에 추가될 수 있으니 BEGIN ~ END로 묶음
DROP PROCEDURE IF EXISTS ifPRoc1; -- 만약 기존에 ifProc()을 만든 적이 있다면 삭제
DELIMITER $$ -- 세미콜론으로는 SQL의 끝인지 스토어드 프로시저의 끝인지 구분하기 힘들기 때문에 $$를 사용
CREATE PROCEDURE ifProc1() -- 프로시저의 이름은 ifProc1()
BEGIN
	IF 100 = 100 THEN
	SELECT '100은 100과 같습니다.';
	END IF;
END $$
DELIMITER ;
CALL ifProc1();

-- if ~ else문
-- > 조건에 따라 다른 부분을 수행
DROP PROCEDURE IF EXISTS ifProc2;
DELIMITER $$
CREATE PROCEDURE ifProc2()
BEGIN
	DECLARE myNum INT; -- myNum 변수 선언. 변수의 데이터 형식은 INT
	SET myNum = 200; -- myNum 변수에 200을 대입
	IF myNum = 100 THEN -- myNum이 100인지 아닌지 판단
		SELECT '100 입니다.';
	ELSE
		SELECT '100이 아닙니다.';
	END IF;
END $$
DELIMITER ;
CALL ifProc2();

-- SELECT ~ INTO ~ 문
-- > SELECT의 결과를 INTO 뒤의 변수에 저장
SELECT debut_date INTO @debutDate FROM market_db.`member` m  WHERE mem_id = 'APN';
SELECT @debutDate;

-- > 스토어드 프로시저에서 변수는 DECLARE로 선언한 후에 사용하지만
-- > 일반 SQL에서 변수는 @변수명으로 지정하고 별도의 선언 없이 사용할 수 있음

-- 날짜 관련함수
CURRENT_DATE(); -- 오늘 날짜를 가져오기
CURRENT_TIMESTAMP(); -- 오늘 날짜 및 시간을 함께 가져오기
DATEDIFF(날짜1, 날짜2); -- 날짜2부터 날짜1까지 일수로 며칠인지 계산하기
SELECT CURRENT_DATE(), DATEDIFF('2023-12-31','2000-1-1');

-- IF문의 활용
-- > 아이디가 APN인 회원의 데뷔일자가 5년이 넘었는지 확인해보고 5년이 넘었으면 축하 메시지를 출력
DROP PROCEDURE IF EXISTS ifProc3;
DELIMITER $$
CREATE PROCEDURE ifProc3()
BEGIN
	DECLARE debutDate DATE;
	DECLARE today DATE;
	DECLARE days INT;

	SELECT debut_date INTO debutDate
	FROM `member` m 
	WHERE mem_id = 'APN';

	SET today = CURRENT_DATE();
	SET days = DATEDIFF(CURRENT_DATE(), debutDate);
	if (days / 365) >= 5 THEN
		SELECT '데뷔 5년차가 넘은걸 축하드립니다.';
	ELSE 
		SELECT '아직 데뷔 5년차가 아닙니다.';
	END IF;
END $$
DELIMITER ;

CALL ifProc3();

-- CASE 문
-- > 여러가지 조건 중에서 선택해야 하는 다중 분기에서 사용

-- CASE 문의 기본 형식
CASE 
	WHEN 조건1 THEN
		SQL 문장들1
	WHEN 조건2 THEN
		SQL 문장들2
	ELSE
		SQL 문장들3
END CASE;
-- > CASE와 END CASE 사이에는 여러 조건들을 넣을 수 있음
-- > 조건이 여러 개라면 WHEN을 여러번 반복하고 모든 조건에 해당하지 않으면 마지막에 ELSE 부분을 수행

-- 학점을 부여할 때 90점 이상은 A, 80점 이상은 B, 70점 이상은 C, 60점 이상은 D, 60점 미만은 F로 처리하는 경우
DROP PROCEDURE IF EXISTS caseProc;

DELIMITER $$
CREATE PROCEDURE caseProc()
BEGIN
	DECLARE point INT;
	DECLARE credit CHAR(1);

	SET point = 88;
	
	CASE 
		WHEN point >= 90 THEN SET credit = 'A';
		WHEN point >= 80 THEN SET credit = 'B';
		WHEN point >= 70 THEN SET credit = 'C';
		WHEN point >= 60 THEN SET credit = 'D';
		ELSE 				  SET credit = 'F';
	END CASE;	
	SELECT CONCAT ('취득점수 => ', point), CONCAT('학점 => ', credit);		
END $$
DELIMITER ;
CALL caseProc();

-- CASE문의 활용
-- 인터넷 마켓 데이터베이스의 회원들의 총 구매액을 계산해서 회원의 등급을 아래와 같이 4간계로 나누려함
-- > 총구매액이 1500 이상이면 최우수고객
-- > 총구매액이 1000 ~ 1499 우수고객
-- > 총구매액이 1 ~ 999 일반고객
-- > 총구매액이 0이하 유령고객
 

SELECT b.mem_id , m.mem_name ,SUM(b.price * b.amount) 총구매액,
	CASE 
		WHEN (SUM(b.price * b.amount) >= 1500) THEN '최우수고객'
		WHEN (SUM(b.price * b.amount) >= 1000) THEN '우수고객'
		WHEN (SUM(b.price * b.amount) >= 1) THEN '일반고객'
		ELSE '유령고객'
	END 회원등급
FROM buy b 
	RIGHT OUTER JOIN `member` m 
	ON b.mem_id = m.mem_id 
GROUP BY b.mem_id , m.mem_name 
ORDER BY SUM(b.price * b.amount ) DESC;

-- WHILE문의 기본형식
WHILE <조건식> DO
	SQL 문장들
END WHILE;

-- > 1에서 100까지의 값을 모두 더하는 기능 구현
DROP PROCEDURE IF EXISTS whileProc;
DELIMITER $$
CREATE PROCEDURE whileProc()
BEGIN
	DECLARE i INT; -- 1에서 100까지 증가할 변수
	DECLARE hap INT;
	SET i = 1;
	SET hap = 0;

	WHILE (1<= 100) DO
		SET hap = hap + i;
		SET i = i + 1;
	END WHILE;
	SELECT '1부터 100까지의 합', hap;
END $$
DELIMITER ;

CALL whileProc();

-- WHILE문의 응용
-- > ITERATE [레이블] : 지정한 레이블로 돌아가 계속 진행 파이썬의 continue와 유사
-- > LEAVE [레이블] : 지정한 레이블을 빠져나감 WHILE문이 종료

-- 1에서 100까지 합계에서 4의 배수를 제외하고 합계가 1000이 넘으면 더하는 것을 그만두고
-- 1000이 넘는 순간의 숫자를 출력한 후 프로그램 종료
DROP PROCEDURE IF EXISTS whileProc2;

DELIMITER $$
CREATE PROCEDURE whileProc2()
BEGIN
	DECLARE i INT; -- 1에서 100까지 증가할 변수
	DECLARE hap INT;
	SET i = 1;
	SET hap = 0;
	
	myWhile: 
	WHILE (i<= 100 )DO
		IF (i % 4 = 0) THEN		
			SET i = i + 1;
			ITERATE myWhile; 
		END IF;
		
		SET hap = hap + i;
	
		IF (hap >1000) THEN
			LEAVE myWhile;
		END IF;
		
		SET i = i + 1;
		
		
	END WHILE;

	SELECT '1부터 100까지의 합', hap;
END $$
DELIMITER ;
CALL whileProc2();
-- 동적 SQL
-- > SQL은 내용이 고정되어 있는 경우가 대부분이지만 상황에 따라 내용 변경이 필요할 때
-- > 동적 SQL을 사용하면 변경되는 내용을 실시간으로 적용시켜 사용할 수 있음

-- PREPARE와 EXECUTE
-- > PREPARE : SQL문을 실행하지는 않고 미리 준비만 해둠
-- > EXCUTE : 준비한 SQL문을 실행
-- -- 실행한 후에는 DEALLOCATE PREAPRE 로 문장을 해제
PREPARE myQuery FROM 'SELECT * FROM member WHERE mem_id = "BLK"';
EXECUTE myQuery;
DEALLOCATE PREPARE myQuery;

-- 동적 SQL의 활용
-- > PREPARE문에서는 ? 로 향후에 입력될 값을 비워두고 EXECUTE 에서 USING으로 ? 에 값을 전달할 수 있음
-- > 실시간으로 필요한 값들을 전달해서 동적으로 SQL이 실행

-- > 보안이 중요한 출입문 에서는 출입한 내역을 테이블에 기록하는 데
-- > 이때 출입증을 태그하는 순간의 날짜와 시간이 INSERT문으로 입력되도록 코드 작성
DROP TABLE IF EXISTS gate_table;
CREATE TABLE gate_table (
	id			INT AUTO_INCREMENT PRIMARY KEY,
	entry_time	DATETIME		
); -- 출입 기록용 테이블 생성

SET @curDate = CURRENT_TIMESTAMP(); -- 현재 날짜와 시간
PREPARE myQuery FROM 'INSERT INTO gate_table(entry_time) VALUES (?)';
-- > ?를 사용해서 entry_time 에 입력할 값을 비워둠

EXECUTE myQuery USING @curDate;

DEALLOCATE PREPARE myQuery;

SELECT * FROM gate_table gt ;



