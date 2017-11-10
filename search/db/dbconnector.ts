
import { Person } from './../types/person';

export interface DbConnector {
    init(): Promise<boolean>;
    searchPersons(lastname: string, city: string): Promise<Person[]>;
    upsert(person: Person): Promise<void>;
    updateChangeSeqid(table: string, changeseqid: number): Promise<void>;
    bulkCreate(persons: Person[]): Promise<void>;
    getCities(): Promise<string[]>;
    getChangeSeqId(): Promise<string[]>;
}