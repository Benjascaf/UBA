import 'dotenv/config'
import { Client, QueryResult } from 'pg'
import { readFile } from 'node:fs/promises';
import { PathLike } from 'node:fs';

type Alumno = {lu: string, apellido: string, titulo: string, titulo_en_tramite: Date, egreso: Date}

async function leerYParsearCsv(filePath: PathLike){
    const contents: string = await readFile(filePath, { encoding: 'utf8' });
    const header: string = contents.split(/\r?\n/)[0];
    const columns: string[] = header.split(',').map((col: string) => col.trim());
    const dataLines: string[] = contents.split(/\r?\n/).slice(1).filter((line: string) => line.trim() !== '');
    // Noc si ponerle tipo a este coso (Hernán me putearía)
    return {dataLines, columns};
}

async function refrescarTablaAlumnos(clientDb: Client, listaDeAlumnosCompleta: string[], columnas: string[]): Promise<void> {
    await clientDb.query("DELETE FROM aida.alumnos");
    for (const line of listaDeAlumnosCompleta) {
        const values: string[] = line.split(',');
        // Esto está feo
        const query: string = `
            INSERT INTO aida.alumnos (${columnas.join(', ')}) VALUES
                (${values.map((value: string) => value == '' ? 'null' : `'` + value + `'`).join(', ')})
        `;
        console.log(query)
        //Esto noc como tiparlo mejor
        const res: QueryResult<any> = await clientDb.query(query)
        console.log(res.command, res.rowCount)
    }
}

async function obtenerPrimerAlumnoQueNecesitaCertificado(clientDb: Client): Promise<Alumno | null> {
    const sql = `SELECT *
    FROM aida.alumnos
    WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL
    ORDER BY egreso
	LIMIT 1`;
    const res: QueryResult<any> = await clientDb.query(sql)
    if (res.rows.length > 0){
        return res.rows[0];
    } else {
        return null;
    }
}


async function generarCertificadoParaAlumno(clientDb: Client, alumno: Alumno): Promise<void> {
    console.log('alumno', alumno);
}

async function principal(): Promise<void> {
    const clientDb: Client = new Client()
    const filePath: PathLike = `../recursos/alumnos.csv`;
    await clientDb.connect()
    //Esto noc si tiparlo
    var {dataLines: listaDeAlumnosCompleta, columns: columnas} = await leerYParsearCsv(filePath)
    await refrescarTablaAlumnos(clientDb, listaDeAlumnosCompleta, columnas);
    var alumno: Alumno | null = await obtenerPrimerAlumnoQueNecesitaCertificado(clientDb);
    if (alumno == null){
        console.log('No hay alumnos que necesiten certificado');
    } else {
        await generarCertificadoParaAlumno(clientDb, alumno);
    }
    await clientDb.end()
}

principal();