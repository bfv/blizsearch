
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
                    console.log('database connected');
                    this.db = db;
                    this.persons = db.collection('persons');
                    this.changeseq = db.collection('changeseq');
                    resolve(true);
                }
                else {
                    reject('MongoDB not connected');
                }
            });  
            
        });
        return promise;
    }

    public upsert(person: Person): void {
        //console.log('upsert: ', person);
        this.persons.update({ id: person.id}, person, { upsert: true });
    }

    public bulkCreate(persons: Person[], callback): void {
        this.persons.insertMany(persons, (err, db) => {
            if (err) {
                console.log(err.message);
            }
            callback();
        });
    }

    public updateChangeSeqid(table: string, changeseqid: number, callback): void {
        //this.system.update({ id: 1}, { id: 1, changeseqid: changeseqid }, { upsert: true });
        this.changeseq.update({ table: table}, { table: table, changeseqid: changeseqid}, { upsert: true });
        callback();
    }

    public searchPersons(lastname: string, city: string, callback): void {

        let persons: Person[];
        let criteria = {};

        if (lastname && lastname != '') {
            criteria['lastname'] = lastname;
        }

        if (city && city != '') {
            criteria['address.city'] = city;
        }
        
        console.log('begin search: ', criteria);

        this.persons.find(criteria).toArray().then(data => {
            //console.log(JSON.stringify(data));
            console.log('done');
            persons = <Person[]> data;
            callback(persons);
        });
        
    }

    public getCities(callback):void {
        this.persons.distinct('address.city', null).then(
            data => {
                callback(<string[]> data);
            }
        )
    }

    public getChangeSeqId(callback) {
        this.changeseq.find({}).toArray().then(
            data => {
                callback(data);
            }
        )
    }
}