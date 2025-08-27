create user aida_owner nologin;
create user aida_admin password "cambiar esto";

create database aida_db;
grant usage on database aida_db to aida_admin;
