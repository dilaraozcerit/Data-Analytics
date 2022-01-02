--====================================================================================================================
----------------------------------------- DATABASE MODELING & DESIGN LECTURE -----------------------------------------
--------------------------------------------- UNIVERSITY DATABASE PROJECT --------------------------------------------  
--====================================================================================================================

---------- CREATE DATABASE

CREATE DATABASE university_registration;

---------- CREATE TABLES 

-- Student Table

CREATE TABLE student (
    student_id int primary key identity (1,1) not null,
    first_name nvarchar(50) not null,
    last_name nvarchar(50) not null,
    registration_date date not null,
    region nvarchar(20) not null
);

-- Staff Table

CREATE TABLE staff (
    staff_id int primary key identity (1,1) not null,
    first_name nvarchar(50) not null,
    last_name nvarchar(50) not null,
    region nvarchar(20) not null
);

-- Course Table

use university_registration
go

create function dbo.fn_check_credit (
    @course_title nvarchar(50),
    @course_credit tinyint
)
returns varchar(10)
as 
begin
    declare @credit_real tinyint
    declare @credit_result varchar(10)
    if @course_title in ('Fine Arts', 'German', 'Biology')
        set @credit_real = 15
    else 
        set @credit_real = 30 
    if @course_credit = @credit_real 
        set @credit_result = 'True'
    else 
        set @credit_result = 'False'
    return @credit_result
end

CREATE TABLE course (
    course_id int primary key identity (1,1) not null,
    course_title nvarchar(50) not null,
    course_credit tinyint not null,
    constraint credit_check
    check (dbo.fn_check_credit(course_title, course_credit) = 'True')
);

-- Duty Table

CREATE TABLE duty (
    duty_id tinyint not null,
    staff_id int not null, 
    duty_name nvarchar(20) not null,
    constraint fk_staffid foreign key (staff_id) references staff (staff_id) on update cascade on delete cascade, 
    constraint pk_duty primary key (duty_id, staff_id)
);

-- Student_Staff Table

use university_registration
go 

create function dbo.fn_check_region (
    @student_id int,
    @staff_id int
)
returns varchar(10)
as 
begin 
    declare @result varchar(20)
    declare @student_result varchar(20) 
    declare @staff_result varchar(10)
    select @student_result = region from student where student_id = @student_id
    select @staff_result = region from staff where staff_id = @staff_id
    if @student_result = @staff_result
        set @result = 'True'
    else 
        set @result = 'False'
    return @result 
end;

CREATE TABLE student_staff (
    student_id int not null,
    staff_id int not null, 
    duty_id tinyint not null,
    constraint fk_student foreign key (student_id) references student (student_id) on update cascade on delete cascade,
    constraint fk_duty foreign key (duty_id, staff_id) references duty (duty_id, staff_id) on update cascade on delete cascade,
    constraint sstaff_pk primary key (student_id, staff_id, duty_id),
    constraint region_control2
    check (dbo.fn_check_region(student_id, staff_id) = 'True')
);

-- Staff_Course Table

CREATE TABLE staff_course (
    staff_id int not null,
    course_id int not null, 
    constraint fk_staff3 foreign key (staff_id) references staff (staff_id) on update cascade on delete cascade,
    constraint fk_course2 foreign key (course_id) references course (course_id) on update cascade on delete cascade,
    constraint sstaff_pk3 primary key (staff_id, course_id)
);

-- Student_Course Table

create function dbo.fn_course_constraint (
    @student_id int
)
returns varchar(10)
as 
begin 
    declare @total_credit int 
    declare @result varchar(10)
    select @total_credit = sum(c.course_credit) from course c join student_course sc on c.course_id=sc.course_id 
        where sc.student_id = @student_id
    if @total_credit <= 180
        set @result = 'True'
    else 
        set @result = 'False'
    return @result
end

-----

create function dbo.fn_course_region (
    @student_id int,
    @course_id int
)
returns varchar(10)
as 
begin 
    declare @result varchar(20)
    declare @student_result varchar(20) 
    select @student_result = region from student where student_id = @student_id
    if @student_result in (select st.region from course c join staff_course sc on c.course_id=sc.course_id 
        join staff st on sc.staff_id=st.staff_id where c.course_id = @course_id)
        set @result = 'True'
    else 
        set @result = 'False'
    return @result 
end;

CREATE TABLE student_course (
    student_id int not null,
    course_id int not null, 
    constraint fk_student2 foreign key (student_id) references student (student_id) on update cascade on delete cascade,
    constraint fk_course foreign key (course_id) references course (course_id) on update cascade on delete cascade,
    constraint sstaff_pk2 primary key (student_id, course_id),
    constraint course_control
    check (dbo.fn_course_constraint(student_id) = 'True'),
    constraint region_control
    check (dbo.fn_course_region(student_id, course_id) = 'True')
);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
---------- INSERTING THE VALUES INTO THE TABLES

-- Student Table

insert student values ('Alec', 'Hunter', '2020-05-12', 'Wales'),
                ('Browning', 'Blueberry', '2020-05-12', 'Scotland'),
                ('Charlie', 'Apricot', '2020-05-12', 'England'), 
                ('Ursula', 'Douglas', '2020-05-12', 'Scotland'),
                ('Zorro', 'Apple', '2020-05-12', 'England'),
                ('Debbie', 'Orange', '2020-05-12', 'Wales')

-- Staff Table 

insert staff values ('October', 'Lime', 'Wales'),
                ('Ross', 'Island', 'Scotland'),
                ('Harry', 'Smith', 'England'), 
                ('Neil', 'Mango', 'Scotland'),
                ('Kellie', 'Pear', 'England'),
                ('Victor', 'Fig', 'Wales'),
                ('Margeret', 'Nolan', 'England'),
                ('Yavette', 'Berry', 'Northern Ireland'),
                ('Tom', 'Garden', 'Northern Ireland')

-- Course Table

insert course values ('Fine Arts', 15),
                     ('German', 15),
                     ('Chemistry', 30),
                     ('French', 30),
                     ('Physics', 30),
                     ('History', 30),
                     ('Music', 30),
                     ('Psychology', 30),
                     ('Biology', 15)

-- Duty Table

insert duty values (1, 1, 'counsel'),
                   (1, 2, 'counsel'),
                   (1, 3, 'counsel'),
                   (1, 4, 'counsel'),
                   (1, 5, 'counsel'),
                   (1, 6, 'counsel'),
                   (2, 4, 'tutor'),
                   (2, 3, 'tutor'),
                   (2, 7, 'tutor'),
                   (2, 8, 'tutor'),
                   (2, 9, 'tutor')

-- Student_Staff Table

insert student_staff values (1, 1, 1),
                            (2, 2, 1),
                            (3, 3, 1),
                            (4, 4, 1),
                            (5, 5, 1),
                            (6, 6, 1),
                            (1, 4, 2),
                            (1, 3, 2),
                            (2, 4, 2),
                            (2, 3, 2),
                            (3, 4, 2),
                            (3, 3, 2),
                            (4, 4, 2),
                            (4, 3, 2)

-- While inserting this table I received an error since some of the students are not associated with tutors
-- who have the same nationality as them.

-- Staff_Course Table

insert staff_course values (4, 1),
                           (3, 2),
                           (7, 3),
                           (5, 4),
                           (7, 4),
                           (3, 5),
                           (5, 5),
                           (8, 9)

-- Student_Course Table

insert student_course values (1, 1),
                             (1, 2),
                             (2, 1),
                             (2, 2),
                             (3, 1),
                             (3, 2),
                             (4, 1),
                             (4, 2)

-- While inserting this table I received an error since some of the students are not associated with tutors
-- who have the same nationality as them.

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------- CONSTRAINTS

-- 1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	  They may not take courses simultaneously if their combined points total exceeds 180 points.

-- I have already executed the below code before creating the student_course table.

create function dbo.fn_course_constraint (
    @student_id int
)
returns varchar(10)
as 
begin 
    declare @total_credit int 
    declare @result varchar(10)
    select @total_credit = sum(c.course_credit) from course c join student_course sc on c.course_id=sc.course_id where sc.student_id = @student_id
    if @total_credit <= 180
        set @result = 'True'
    else 
        set @result = 'False'
    return @result
end

-- Now, none of the students were enrolled in courses. Through the query below, some of the students will be enrolled in several courses.

insert student_course values (2, 1),
                             (3, 2),
                             (3, 3),
                             (3, 4),
                             (3, 5)
                             

-- The current status can be seen through the below query:

select st.student_id, st.course_id, c.course_title, c.course_credit
from student_course st join course c on st.course_id=c.course_id

-- Unfortunately it is not possible to add more courses to the students using the Excel table
-- due to the incompatibility between the regions of students and tutors.

--------------------------------------------------------------------------------------------
-- 2. The student's region and the counselor's region must be the same.

-- I have already executed the below code before creating the student_staff table.

create function dbo.fn_check_region (
    @student_id int,
    @staff_id int
)
returns varchar(10)
as 
begin 
    declare @result varchar(20)
    declare @student_result varchar(20) 
    declare @staff_result varchar(10)
    select @student_result = region from student where student_id = @student_id
    select @staff_result = region from staff where staff_id = @staff_id
    if @student_result = @staff_result
        set @result = 'True'
    else 
        set @result = 'False'
    return @result 
end;

/* Now, the student_staff table is empty.
If I run the below query, I will only insert the counselors who have the same nationality with the students in the student table.
Therefore, the query will successfull run.*/

insert student_staff values (1, 1, 1),
                            (2, 2, 1),
                            (3, 3, 1),
                            (4, 4, 1),
                            (5, 5, 1),
                            (6, 6, 1)

-- You can see from the below query, all students have counselors who have the same nationality with them.

select s.student_id, s.first_name, s.last_name, s.region, st.staff_id, st.first_name, st.last_name, d.duty_name, st.region
from student s join student_staff ss on s.student_id=ss.student_id join duty d on (ss.duty_id=d.duty_id and ss.staff_id=d.staff_id)
join staff st on d.staff_id=st.staff_id

-- However, if I insert a tutor who has a different nationality, the query will not successfully run.
-- For example, if I try to insert Neil Mango as the Fine Arts tutor of Alec Hunter, the query will not work.

insert student_staff values (1, 4, 2)

---------- ADDITIONALLY TASKS

-- 1. Test the credit limit constraint.

-- I have already done this at Constraints, question number 1.

-- 2. Test that you have correctly defined the constraint for the student counsel's region. 

-- I have already done this at Constraints, question number 2.

-- 3. Try to set the credits of the History course to 20. (You should get an error.)

-- I have already executed the below code before creating the course table.

create function dbo.fn_check_credit (
    @course_title nvarchar(50),
    @course_credit tinyint
)
returns varchar(10)
as 
begin
    declare @credit_real tinyint
    declare @credit_result varchar(10)
    if @course_title in ('Fine Arts', 'German', 'Biology')
        set @credit_real = 15
    else 
        set @credit_real = 30 
    if @course_credit = @credit_real 
        set @credit_result = 'True'
    else 
        set @credit_result = 'False'
    return @credit_result
end



-- If I try to run the below query, the query will not run and it will return an error message.

insert course values ('History', 20)



-- 4. Try to set the credits of the Fine Arts course to 30. (You should get an error.)

-- If I try to run the below query, the query will not run and it will return an error message.

insert course values ('Fine Arts', 30)



-- 5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)

select * from student;
select * from course;

-- Using the above queries I can see that Debbie Orange's student_id is 6 and the course_id of Chemistry is 3.
-- Since Debbie is from Wales and the tutor of the Chemistry class is from England, the below query will not run.

insert student_course values (6, 4)




-- 6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)

-- Using the below query, we can get the current counsels of student.

select s.student_id, s.first_name, s.last_name, s.region, st.staff_id, st.first_name, st.last_name, d.duty_name
from student s join student_staff ss on s.student_id=ss.student_id 
join duty d on (ss.staff_id=d.staff_id and ss.duty_id=d.duty_id) 
join staff st on d.staff_id=st.staff_id;

select * from student_staff

-- Using the below query, we can see the region of Tom Garden.

select *
from staff 
where first_name = 'Tom'

-- If I try to set Tom Garden (staff_id = 9) as counsel (duty_id = 1) of Alec Hunter (student_id = 1),
-- the query will return an error message and will not run.

insert student_staff values (1, 9, 1)



-- 7. Swap counselors of Ursula Douglas and Bronwin Blueberry.

update student_staff
set staff_id = 4
where student_id = 2;

update student_staff
set staff_id = 2 
where student_id = 4;



-- 8. Remove a staff member from the staff table.
--	  If you get an error, read the error and update the reference rules for the relevant foreign key.

delete from staff where staff_id = 1

select * from staff

--======================================================================================================

















