import { Client } from 'pg'
const client = new Client();
await client.connect();

const res = await client.query('Select $1::text as message', ['Hello World'])
console.log(res.rows[0].message)
await client.end()
