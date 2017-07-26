
import { Person } from './../types/person';

export interface DbConnector {
    init(): Promise<boolean>;
    searchPersons(lastname: string, city: string, callback): void;
    upsert(person: Person): void;
    updateChangeSeqid(table: string, changeseqid: number, callback): void;
    bulkCreate(persons: Person[], callback): void;
    getCities(callback): void;
    getChangeSeqId(callback);
}