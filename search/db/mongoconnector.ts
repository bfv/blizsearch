
import { Person } from './../types/person';
import { DbConnector } from './dbconnector';
import { MongoClient, Db, Collection } from 'mongodb';
import * as assert from 'assert';

export class MongoConnector implements DbConnector {

    private db: Db; 
    private persons: Collection;
    private changeseq: Collection;

    public init(): Promise<boolean> {
        
        const promise = new Promise<boolean>((resolve, reject) => {
            const client = new MongoClient();

            // change db name to 'blizsearch'
            client.connect('mongodb://localhost:27017/mongotst1', (err, db) => {
                if (!err) {
                    assert.equal(err, null);
                    this.db = db;
                    this.persons = db.collection('persons');
                    this.changeseq = db.collection('changeseq');
                    resolve(true);
                }
                else {
                    reject('MongoDB not connected: ' + err.message); 
                }
            });  
            
        });
        return promise;
    }

    public upsert(person: Person): Promise<void> {
        return new Promise<void>((resolve, reject) => {
            this.persons.update({ id: person.id}, person, { upsert: true }).then(() => {
                resolve();
            }, (err) => {
                reject();
            });
        })
        
    }

    public bulkCreate(persons: Person[]): Promise<void> {
        return new Promise<void>((resolve, reject) => { 
            this.persons.insertMany(persons).then(() => {
                resolve();
            }, (err) => {
                console.log(err.message);
                reject();
            });
        });
    }

    public updateChangeSeqid(table: string, changeseqid: number): Promise<void> {
        //this.system.update({ id: 1}, { id: 1, changeseqid: changeseqid }, { upsert: true });

        return new Promise<void>((resolve, reject) => {
            this.changeseq.update({ table: table}, { table: table, changeseqid: changeseqid}, { upsert: true })
            .then(() => { 
                resolve();
            }, (err) => {
                reject();
            })
        });
    }

    public searchPersons(lastname: string, city: string): Promise<Person[]> {

        let persons: Person[];
        let criteria = {};

        if (lastname && lastname != '') {
            criteria['lastname'] = lastname;
        }

        if (city && city != '') {
            criteria['address.city'] = city;
        }

        console.log('begin search: ', criteria);
        return new Promise<Person[]>((resolve, reject) => {
            this.persons.find(criteria).toArray().then(data => {
                resolve(data);
            });
        });
    }

    public getCities(): Promise<string[]> {
        return this.persons.distinct('address.city', null);
    }

    public getChangeSeqId():Promise<string[]> {
        return this.changeseq.find({}).toArray();
    }
}