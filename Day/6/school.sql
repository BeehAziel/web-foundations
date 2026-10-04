PRAGMA foreign_keys = ON;

CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL
);

CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)
);

INSERT INTO students (student_id, name, email) VALUES
    (1, 'Ava Patel', 'ava@example.com'),
    (2, 'Noah Kim', 'noah@example.com'),
    (3, 'Mia Chen', 'mia@example.com'),
    (4, 'Leo Garcia', 'leo@example.com');

INSERT INTO courses (course_id, course_name) VALUES
    (1, 'Biology'),
    (2, 'Computer Science'),
    (3, 'History');

INSERT INTO enrolments (enrolment_id, student_id, course_id, grade) VALUES
    (1, 1, 1, 'A'),
    (2, 1, 2, 'B'),
    (3, 2, 1, 'B'),
    (4, 3, 2, 'A'),
    (5, 4, 3, 'A');

-- 1. All courses for one student, selected by name.
SELECT c.course_name
FROM students AS s
JOIN enrolments AS e ON e.student_id = s.student_id
JOIN courses AS c ON c.course_id = e.course_id
WHERE s.name = 'Ava Patel';

-- 2. All students on one course.
SELECT s.name
FROM students AS s
JOIN enrolments AS e ON e.student_id = s.student_id
JOIN courses AS c ON c.course_id = e.course_id
WHERE c.course_name = 'Computer Science';

-- 3. Number of students per course, including courses with no students.
SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrolments AS e ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_name;

-- 4. Students who have no enrolments.
SELECT s.name
FROM students AS s
LEFT JOIN enrolments AS e ON e.student_id = s.student_id
WHERE e.enrolment_id IS NULL;

-- 5. Update one enrolment's grade.
UPDATE enrolments
SET grade = 'A'
WHERE student_id = 1 AND course_id = 2;