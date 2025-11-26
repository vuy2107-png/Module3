create database lop;

use lop;

create table Student(
	id int,
    name varchar(200),
    age int,
    country varchar(50)
);

insert into Student values (1, 'Duy', 20, 'Vietnam');

select * from Student;
