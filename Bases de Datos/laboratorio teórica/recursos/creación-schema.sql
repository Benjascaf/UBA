create schema aida;
grant usage schema aida to aida_admin;

create table aida.alumnos {
	lu text primary key, 
	apellido text not null,
	nombres text not null, 
	titulo text,
	titulo_en_transito date, 
	egreso date
}
