"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
var pg_1 = require("pg");
var promises_1 = require("node:fs/promises");
function leerYParsearCsv(filePath) {
    return __awaiter(this, void 0, void 0, function () {
        var contents, header, columns, dataLines;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, (0, promises_1.readFile)(filePath, { encoding: 'utf8' })];
                case 1:
                    contents = _a.sent();
                    header = contents.split(/\r?\n/)[0];
                    columns = header.split(',').map(function (col) { return col.trim(); });
                    dataLines = contents.split(/\r?\n/).slice(1).filter(function (line) { return line.trim() !== ''; });
                    // Noc si ponerle tipo a este coso (Hernán me putearía)
                    return [2 /*return*/, { dataLines: dataLines, columns: columns }];
            }
        });
    });
}
function refrescarTablaAlumnos(clientDb, listaDeAlumnosCompleta, columnas) {
    return __awaiter(this, void 0, void 0, function () {
        var _i, listaDeAlumnosCompleta_1, line, values, query, res;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, clientDb.query("DELETE FROM aida.alumnos")];
                case 1:
                    _a.sent();
                    _i = 0, listaDeAlumnosCompleta_1 = listaDeAlumnosCompleta;
                    _a.label = 2;
                case 2:
                    if (!(_i < listaDeAlumnosCompleta_1.length)) return [3 /*break*/, 5];
                    line = listaDeAlumnosCompleta_1[_i];
                    values = line.split(',');
                    query = "\n            INSERT INTO aida.alumnos (".concat(columnas.join(', '), ") VALUES\n                (").concat(values.map(function (value) { return value == '' ? 'null' : "'" + value + "'"; }).join(', '), ")\n        ");
                    console.log(query);
                    return [4 /*yield*/, clientDb.query(query)];
                case 3:
                    res = _a.sent();
                    console.log(res.command, res.rowCount);
                    _a.label = 4;
                case 4:
                    _i++;
                    return [3 /*break*/, 2];
                case 5: return [2 /*return*/];
            }
        });
    });
}
function obtenerPrimerAlumnoQueNecesitaCertificado(clientDb) {
    return __awaiter(this, void 0, void 0, function () {
        var sql, res;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    sql = "SELECT *\n    FROM aida.alumnos\n    WHERE titulo IS NOT NULL AND titulo_en_tramite IS NOT NULL\n    ORDER BY egreso\n\tLIMIT 1";
                    return [4 /*yield*/, clientDb.query(sql)];
                case 1:
                    res = _a.sent();
                    if (res.rows.length > 0) {
                        return [2 /*return*/, res.rows[0]];
                    }
                    else {
                        return [2 /*return*/, null];
                    }
                    return [2 /*return*/];
            }
        });
    });
}
function generarCertificadoParaAlumno(clientDb, alumno) {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            console.log('alumno', alumno);
            return [2 /*return*/];
        });
    });
}
function principal() {
    return __awaiter(this, void 0, void 0, function () {
        var clientDb, filePath, _a, listaDeAlumnosCompleta, columnas, alumno;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    clientDb = new pg_1.Client();
                    filePath = "../recursos/alumnos.csv";
                    return [4 /*yield*/, clientDb.connect()
                        //Esto noc si tiparlo
                    ];
                case 1:
                    _b.sent();
                    return [4 /*yield*/, leerYParsearCsv(filePath)];
                case 2:
                    _a = _b.sent(), listaDeAlumnosCompleta = _a.dataLines, columnas = _a.columns;
                    return [4 /*yield*/, refrescarTablaAlumnos(clientDb, listaDeAlumnosCompleta, columnas)];
                case 3:
                    _b.sent();
                    return [4 /*yield*/, obtenerPrimerAlumnoQueNecesitaCertificado(clientDb)];
                case 4:
                    alumno = _b.sent();
                    if (!(alumno == null)) return [3 /*break*/, 5];
                    console.log('No hay alumnos que necesiten certificado');
                    return [3 /*break*/, 7];
                case 5: return [4 /*yield*/, generarCertificadoParaAlumno(clientDb, alumno)];
                case 6:
                    _b.sent();
                    _b.label = 7;
                case 7: return [4 /*yield*/, clientDb.end()];
                case 8:
                    _b.sent();
                    return [2 /*return*/];
            }
        });
    });
}
principal();
