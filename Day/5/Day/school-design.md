# School Database Design

## Tables

- **students** stores each student's name and unique email address.
- **courses** stores the names of courses offered by the school.
- **enrolments** records which student takes which course, along with that student's grade for the course.

## Relationships

A student can have many enrolments, and a course can have many enrolments; each enrolment belongs to one student and one course. This makes students and courses a many-to-many relationship. The `enrolments` join table is needed to represent that relationship and store its grade. Its unique constraint prevents a student from enrolling in the same course twice.

## Index

I would add an index on `enrolments(course_id)`. It can speed up queries that find students on a course or count enrolments per course.

## SQL or NoSQL?

I would choose SQL for this system. Students, courses, and enrolments have clear relationships and constraints, such as unique student emails and preventing duplicate enrolments. A relational database enforces these rules and supports the joins needed for the school's queries. SQLite is also a good fit for a small system.