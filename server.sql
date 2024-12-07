POSTGRES=# CREATE DATABASE QUIZ_APP;

CREATE DATABASE
POSTGRES=# \C QUIZ_APP;

-- Connect to the 'quiz_app' database
INVALID INTEGER VALUE "to" FOR CONNECTION OPTION "port"
PREVIOUS CONNECTION KEPT
POSTGRES=# \C QUIZ_APP;

YOU ARE NOW CONNECTED TO DATABASE "quiz_app" AS USER "postgres".
QUIZ_APP=# -- Create Users Table
QUIZ_APP=# CREATE TABLE USERS (
QUIZ_APP(# ID SERIAL PRIMARY KEY,
QUIZ_APP(# NAME VARCHAR(255) NOT NULL,
QUIZ_APP(# EMAIL VARCHAR(255) UNIQUE NOT NULL,
QUIZ_APP(# PASSWORD TEXT NOT NULL,
QUIZ_APP(# ROLE VARCHAR(50) DEFAULT 'user' -- 'user' or 'admin'
QUIZ_APP(# );

CREATE TABLE QUIZ_APP=# QUIZ_APP=# -- Create Quizzes Table
QUIZ_APP=# CREATE TABLE QUIZZES (
    QUIZ_APP(# ID SERIAL PRIMARY KEY, QUIZ_APP(# TITLE VARCHAR(255) NOT NULL, QUIZ_APP(# DESCRIPTION TEXT, QUIZ_APP(# TIME_LIMIT INT, -- Time limit in minutes
    QUIZ_APP(# START_DATE TIMESTAMP, QUIZ_APP(# END_DATE TIMESTAMP, QUIZ_APP(# CREATED_BY INT REFERENCES USERS(ID) ON DELETE CASCADE, -- Admin ID
    QUIZ_APP(# IS_ACTIVE BOOLEAN DEFAULT TRUE -- Quiz status
    QUIZ_APP(# );

CREATE TABLE QUIZ_APP=# QUIZ_APP=# -- Create Questions Table
QUIZ_APP=# CREATE TABLE QUESTIONS (
    QUIZ_APP(# ID SERIAL PRIMARY KEY, QUIZ_APP(# QUIZ_ID INT REFERENCES QUIZZES(ID) ON DELETE CASCADE, QUIZ_APP(# QUESTION_TEXT TEXT NOT NULL, QUIZ_APP(# TYPE VARCHAR(50) NOT NULL, -- 'multiple-choice', 'true-false', 'fill-in-the-blank'
    QUIZ_APP(# CORRECT_ANSWER TEXT -- Correct answer for the question
    QUIZ_APP(# );

CREATE TABLE QUIZ_APP=# QUIZ_APP=# -- Create Options Table
QUIZ_APP=# CREATE TABLE OPTIONS (
    QUIZ_APP(# ID SERIAL PRIMARY KEY, QUIZ_APP(# QUESTION_ID INT REFERENCES QUESTIONS(ID) ON DELETE CASCADE, QUIZ_APP(# OPTION_TEXT TEXT NOT NULL QUIZ_APP(# );

CREATE TABLE QUIZ_APP=# QUIZ_APP=# -- Create Submissions Table
QUIZ_APP=# CREATE TABLE SUBMISSIONS (
    QUIZ_APP(# ID SERIAL PRIMARY KEY, QUIZ_APP(# USER_ID INT REFERENCES USERS(ID) ON DELETE CASCADE, QUIZ_APP(# QUIZ_ID INT REFERENCES QUIZZES(ID) ON DELETE CASCADE, QUIZ_APP(# SCORE INT NOT NULL, -- User's score for the quiz
    QUIZ_APP(# TOTAL_QUESTIONS INT NOT NULL, -- Total questions in the quiz
    QUIZ_APP(# DATE_TAKEN TIMESTAMP DEFAULT NOW() QUIZ_APP(# );

CREATE TABLE QUIZ_APP=# -- Add Users
QUIZ_APP=# INSERT INTO USERS (
    NAME,
    EMAIL,
    PASSWORD,
    ROLE
) VALUES  (
    'Admin',
    'admin@example.com',
    'securepassword',
    'admin'
),
 (
    'User1',
    'user1@example.com',
    'securepassword',
    'user'
);

INSERT 0 2 QUIZ_APP=# QUIZ_APP=# -- Add Quizzes
QUIZ_APP=# INSERT INTO QUIZZES (
    TITLE,
    DESCRIPTION,
    TIME_LIMIT,
    START_DATE,
    END_DATE,
    CREATED_BY,
    IS_ACTIVE
) VALUES  (
    'General Knowledge Quiz',
    'Test your general knowledge skills with this fun quiz!',
    20,
    '2024-11-01 00:00:00',
    '2024-12-01 00:00:00',
    1,
    TRUE
),
 (
    'JavaScript Basics',
    'A quiz for beginners to test their JavaScript knowledge.',
    15,
    '2024-11-15 00:00:00',
    '2024-12-15 00:00:00',
    1,
    TRUE
);

INSERT 0 2 QUIZ_APP=# QUIZ_APP=# -- Add Questions
QUIZ_APP=# INSERT INTO QUESTIONS (
    QUIZ_ID,
    QUESTION_TEXT,
    TYPE,
    CORRECT_ANSWER
) VALUES  (
    1,
    'What is the capital of France?',
    'multiple-choice',
    'Paris'
),
 (
    1,
    'True or False: The Earth is flat.',
    'true-false',
    'False'
),
 (
    1,
    'Fill in the blank: The tallest mountain in the world is _____.',
    'fill-in-the-blank',
    'Mount Everest'
),
 (
    2,
    'What is a variable in JavaScript?',
    'multiple-choice',
    'A container for storing data values'
);

INSERT 0 4 QUIZ_APP=# QUIZ_APP=# -- Add Options for Multiple-Choice Questions
QUIZ_APP=# INSERT INTO OPTIONS (
    QUESTION_ID,
    OPTION_TEXT
) VALUES  (
    1,
    'Berlin'
),
 (
    1,
    'Madrid'
),
 (
    1,
    'Paris'
),
 (
    1,
    'Lisbon'
),
 (
    4,
    'A container for storing data values'
),
 (
    4,
    'A CSS framework'
),
 (
    4,
    'A JavaScript framework'
),
 (
    4,
    'A database'
);

INSERT 0 8 QUIZ_APP=# -- Get all users
QUIZ_APP=#
    SELECT
        *
    FROM
        USERS;

ID | NAME | EMAIL | PASSWORD | ROLE

----+-------+-------------------+----------------+-------
1 | Admin | admin@example.com | securepassword | admin

2 | User1 | user1@example.com | securepassword | user

(2 ROWS) QUIZ_APP=# QUIZ_APP=# -- Get all quizzes
QUIZ_APP=#
SELECT
    *
FROM
    QUIZZES;

ID | TITLE | DESCRIPTION | TIME_LIMIT | START_DATE | END_DATE | CREATED_BY | IS_ACTIVE

----+------------------------+----------------------------------------------------------+------------+---------------------+---------------------+------------+-----------
1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 20 | 2024-11-01 00:00:00 | 2024-12-01 00:00:00 | 1 | t

2 | JavaScript Basics | A quiz for beginners to test their JavaScript knowledge. | 15 | 2024-11-15 00:00:00 | 2024-12-15 00:00:00 | 1 | t

(2 ROWS) QUIZ_APP=# QUIZ_APP=# -- Get all questions for a quiz
QUIZ_APP=#
SELECT
    *
FROM
    QUESTIONS
WHERE
    QUIZ_ID = 1;

ID | QUIZ_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER

----+---------+----------------------------------------------------------------+-------------------+----------------
1 | 1 | What is the capital of France? | multiple-choice | Paris

2 | 1 | True or False: The Earth is flat. | true-false | False

3 | 1 | Fill in the blank: The tallest mountain in the world is _____. | fill-in-the-blank | Mount Everest

(3 ROWS) QUIZ_APP=#
SELECT
    Q.ID,
    Q.TITLE,
    Q.DESCRIPTION,
    COUNT(QUE.ID) AS QUESTIONS_COUNT,
    U.NAME AS CREATED_BY,
    Q.IS_ACTIVE,
    Q.START_DATE,
    Q.END_DATE,
    Q.TIME_LIMIT 
FROM
    QUIZZES Q 
    LEFT JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    JOIN USERS U
    ON Q.CREATED_BY = U.ID 
GROUP BY
    Q.ID,
    U.NAME;

ID | TITLE | DESCRIPTION | QUESTIONS_COUNT | CREATED_BY | IS_ACTIVE | START_DATE | END_DATE | TIME_LIMIT

----+------------------------+----------------------------------------------------------+-----------------+------------+-----------+---------------------+---------------------+------------
1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 3 | Admin | t | 2024-11-01 00:00:00 | 2024-12-01 00:00:00 | 20

2 | JavaScript Basics | A quiz for beginners to test their JavaScript knowledge. | 1 | Admin | t | 2024-11-15 00:00:00 | 2024-12-15 00:00:00 | 15

(2 ROWS) QUIZ_APP=#
SELECT
     Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
     ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS 
FROM
    QUIZZES Q 
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID 
WHERE
    Q.ID = 1 -- Replace 1 with the quiz ID you want
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+------------------------+--------------------------------------------------------+-------------+----------------------------------------------------------------+-------------------+----------------+------------------------------
1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 1 | What is the capital of France? | multiple-choice | Paris | {Berlin, Madrid, Paris, Lisbon}

1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 2 | True or False: The Earth is flat. | true-false | False | {NULL}

1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 3 | Fill in the blank: The tallest mountain in the world is _____. | fill-in-the-blank | Mount Everest | {NULL}

(3 ROWS) QUIZ_APP=#
SELECT
    *
FROM
    USERS;

ID | NAME | EMAIL | PASSWORD | ROLE

----+----------+---------------------+----------------+-------
1 | Admin | admin@example.com | securepassword | admin

2 | User1 | user1@example.com | securepassword | user

3 | John Doe | johndoe@example.com | securepassword | user

(3 ROWS) QUIZ_APP=#
SELECT
    *
FROM
    USERS;

ID | NAME | EMAIL | PASSWORD | ROLE

----+------------+---------------------+----------------+-------
1 | Admin | admin@example.com | securepassword | admin

2 | User1 | user1@example.com | securepassword | user

3 | John Doe | johndoe@example.com | securepassword | user

4 | Admin User | dd@example.com | 123 | admin

(4 ROWS) QUIZ_APP=#
SELECT
    *
FROM
    USERS;

ID | NAME | EMAIL | PASSWORD | ROLE

----+------------+---------------------+----------------+-------
1 | Admin | admin@example.com | securepassword | admin

2 | User1 | user1@example.com | securepassword | user

3 | John Doe | johndoe@example.com | securepassword | user

4 | Admin User | dd@example.com | 123 | admin

(4 ROWS) QUIZ_APP=# CREATE TABLE QUESTIONS ( QUIZ_APP(# ID SERIAL PRIMARY KEY,
QUIZ_APP(# QUIZ_ID INT REFERENCES QUIZZES(ID) ON DELETE CASCADE,
QUIZ_APP(# QUESTION_TEXT TEXT NOT NULL,
QUIZ_APP(# TYPE VARCHAR(50) NOT NULL, -- 'multiple-choice', 'true-false', etc.
QUIZ_APP(# CORRECT_ANSWER TEXT NOT NULL QUIZ_APP(# );

ERROR: RELATION "questions" ALREADY EXISTS
QUIZ_APP=# CREATE TABLE OPTIONS (
QUIZ_APP(# ID SERIAL PRIMARY KEY,
QUIZ_APP(# QUESTION_ID INT REFERENCES QUESTIONS(ID) ON DELETE CASCADE,
QUIZ_APP(# OPTION_TEXT TEXT NOT NULL
QUIZ_APP(# );

ERROR: RELATION "options" ALREADY EXISTS
QUIZ_APP=#  Q.ID AS QUIZ_ID, Q.TITLE, Q.DESCRIPTION, QUE.ID AS QUESTION_ID, QUE.QUESTION_TEXT, QUE.TYPE, QUE.CORRECT_ANSWER,
  ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS
  FROM QUIZZES Q
  JOIN QUESTIONS QUE ON Q.ID = QUE.QUIZ_ID
  LEFT JOIN OPTIONS O ON QUE.ID = O.QUESTION_ID
  WHERE Q.ID = 1 -- Replace 1 with the quiz ID you want
  GROUP BY Q.ID, QUE.ID;

ERROR: SYNTAX ERROR AT OR NEAR "quiz_app"
LINE 1:  Q.ID AS QUIZ_ID, Q.TITLE, Q.DESCRIPTION, QUE....
^
QUIZ_APP=# SELECT
 Q.ID AS QUIZ_ID, Q.TITLE, Q.DESCRIPTION, QUE.ID AS QUESTION_ID, QUE.QUESTION_TEXT, QUE.TYPE, QUE.CORRECT_ANSWER,
 ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS
 FROM QUIZZES Q
 JOIN QUESTIONS QUE ON Q.ID = QUE.QUIZ_ID
 LEFT JOIN OPTIONS O ON QUE.ID = O.QUESTION_ID
 WHERE Q.ID = 1 -- Replace 1 with the quiz ID you want
 GROUP BY Q.ID, QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+------------------------+--------------------------------------------------------+-------------+----------------------------------------------------------------+-------------------+----------------+------------------------------
1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 1 | What is the capital of France? | multiple-choice | Paris | {Berlin, Madrid, Paris, Lisbon}

1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 2 | True or False: The Earth is flat. | true-false | False | {NULL}

1 | General Knowledge Quiz | Test your general knowledge skills with this fun quiz! | 3 | Fill in the blank: The tallest mountain in the world is _____. | fill-in-the-blank | Mount Everest | {NULL}

(3 ROWS) QUIZ_APP=#
SELECT
     Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
     ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS 
FROM
    QUIZZES Q 
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID 
WHERE
    Q.ID = 3 -- Replace 1 with the quiz ID you want
    
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+-------+-------------+-------------+---------------+------+----------------+---------
(0 ROWS) QUIZ_APP=#
SELECT
     Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
     ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS 
FROM
    QUIZZES Q 
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID 
WHERE
    Q.ID = 3 -- Replace 1 with the quiz ID you want
    
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+------------------------+-------------------------------------------------+-------------+-----------------------------------+-----------------+-------------------------------------+-------------------------------------------------------------------------------------------------
3 | General Knowledge Quiz | Test your general knowledge with this fun quiz! | 5 | What is a variable in JavaScript? | multiple-choice | A container for storing data values | {"A container for storing data values", "A CSS framework", "A database", "A JavaScript framework"}

(1 ROW) QUIZ_APP=#
SELECT
     Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
     ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS 
FROM
    QUIZZES Q 
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID 
WHERE
    Q.ID = 3 -- Replace 1 with the quiz ID you want
    
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+------------------------+-------------------------------------------------+-------------+-----------------------------------+-----------------+-------------------------------------+-------------------------------------------------------------------------------------------------
3 | General Knowledge Quiz | Test your general knowledge with this fun quiz! | 5 | What is a variable in JavaScript? | multiple-choice | A container for storing data values | {"A container for storing data values", "A CSS framework", "A database", "A JavaScript framework"}

3 | General Knowledge Quiz | Test your general knowledge with this fun quiz! | 6 | What is a variable in JavaScript? | multiple-choice | A container for storing data values | {"A container for storing data values", "A JavaScript framework", "A database", "A CSS framework"}

(2 ROWS)
SELECT
    Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
    ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS
FROM
    QUIZZES Q
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID
WHERE
    Q.ID = 4 -- Replace 1 with the quiz ID you want
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+---------------------------+------------------------------------------------------+-------------+----------------------------------------------------------------+-------------------+----------------+------------------------------
1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 1 | What is the capital of France? | multiple-choice | Paris | {Berlin, Madrid, Paris, Lisbon}

1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 2 | True or False: The Earth is flat. | true-false | False | {NULL}

1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 3 | Fill in the blank: The tallest mountain in the world is _____. | fill-in-the-blank | Mount Everest | {NULL}

(3 ROWS) QUIZ_APP=#
SELECT
     Q.ID AS QUIZ_ID,
    Q.TITLE,
    Q.DESCRIPTION,
    QUE.ID AS QUESTION_ID,
    QUE.QUESTION_TEXT,
    QUE.TYPE,
    QUE.CORRECT_ANSWER,
     ARRAY_AGG(O.OPTION_TEXT) AS OPTIONS 
FROM
    QUIZZES Q 
    JOIN QUESTIONS QUE
    ON Q.ID = QUE.QUIZ_ID 
    LEFT JOIN OPTIONS O
    ON QUE.ID = O.QUESTION_ID 
WHERE
    Q.ID = 1 -- Replace 1 with the quiz ID you want
    
GROUP BY
    Q.ID,
    QUE.ID;

QUIZ_ID | TITLE | DESCRIPTION | QUESTION_ID | QUESTION_TEXT | TYPE | CORRECT_ANSWER | OPTIONS

---------+---------------------------+------------------------------------------------------+-------------+----------------------------------------------------------------+-------------------+----------------+------------------------------
1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 1 | What is the capital of France? | multiple-choice | Paris | {Berlin, Madrid, Paris, Lisbon}

1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 2 | True or False: The Earth is flat. | true-false | False | {NULL}

1 | abhishek vreated the quiz | This quiz tests your knowledge about general topics! | 3 | Fill in the blank: The tallest mountain in the world is _____. | fill-in-the-blank | Mount Everest | {NULL}

(3 ROWS) QUIZ_APP=# CREATE TABLE SUBMISSIONS ( QUIZ_APP(# ID SERIAL PRIMARY KEY,
QUIZ_APP(# USER_ID INT REFERENCES USERS(ID) ON DELETE CASCADE,
QUIZ_APP(# QUIZ_ID INT REFERENCES QUIZZES(ID) ON DELETE CASCADE,
QUIZ_APP(# SCORE INT NOT NULL, -- User's score for the quiz
QUIZ_APP(# TOTAL_QUESTIONS INT NOT NULL, -- Total number of questions in the quiz
QUIZ_APP(# DATE_TAKEN TIMESTAMP DEFAULT NOW() -- Date and time the quiz was taken
QUIZ_APP(# );

ERROR: RELATION "submissions" ALREADY EXISTS
QUIZ_APP=# SELECT * SUBMISSIONS
 SELECT * SUBMISSIONS;

ERROR: SYNTAX ERROR AT OR NEAR "submissions"
LINE 1: SELECT * SUBMISSIONS
^
QUIZ_APP=# SELECT * SUBMISSIONS;

ERROR: SYNTAX ERROR AT OR NEAR "submissions"
LINE 1: SELECT * SUBMISSIONS;

^
QUIZ_APP=# SELECT * FROM SUBMISSIONS;

ID | USER_ID | QUIZ_ID | SCORE | TOTAL_QUESTIONS | DATE_TAKEN

----+---------+---------+-------+-----------------+------------
(0 ROWS) QUIZ_APP=#





-- 1. Query for Fetching All User Results


quiz_app=# SELECT
     s.user_id,
     u.name AS user_name,
     u.email AS user_email,
     s.quiz_id,
     q.title AS quiz_title,
     s.score,
     s.total_questions,
     s.date_taken
 FROM
     submissions s
 JOIN
     users u ON s.user_id = u.id
 JOIN
     quizzes q ON s.quiz_id = q.id
 ORDER BY
     s.date_taken DESC;
 user_id | user_name |         user_email         | quiz_id |        quiz_title         | score | total_questions |         date_taken
---------+-----------+----------------------------+---------+---------------------------+-------+-----------------+----------------------------
       5 | abhi      | abhisheksolapure@gmail.xom |       4 | kon banaga crore pati     |     0 |               1 | 2024-12-05 17:11:23.131124
       1 | Admin     | admin@example.com          |       1 | abhishek vreated the quiz |     2 |               3 | 2024-12-04 19:52:26.684772
(2 rows)


quiz_app=#