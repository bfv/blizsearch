
import { DbConnector } from './db/dbconnector';
import { NextFunction, Request, Response } from 'express';
import { Person } from './types/person';
import { UpdateDocument } from './types/update-document';
import { UpdateChangeSeg } from './types/update-changeseq';

export class Routes {

    private static connector: DbConnector;

    constructor(connector: DbConnector) {
        Routes.connector = connector;
    }

    public home(req: Request, res: Response, next: NextFunction) {
        
        let persons: Person[];

        res.contentType('application/json');
        res.send({ route: '/', status: 'ok' });
    }

    public search(req: Request, res: Response, next: NextFunction) {

        let persons: Person[];
        console.log('search');
        let lastname = req.query['lastname'];
        let city = req.query['city'];

        const begin = new Date();
        Routes.connector.searchPersons(lastname, city).then((data) => {
            persons = <Person[]> data;

            const end = new Date();            
            console.log('#persons:', persons.length, 'in', end.getTime() - begin.getTime(), '\bms');
            
            res.contentType('application/json');
            res.send(persons);
        });        
    }

    public update(req: Request, res: Response, next: NextFunction) {
        
        let updateDoc: UpdateDocument<Person>;
        let person: Person;
       
        updateDoc = <UpdateDocument<Person>> req.body;        
        person = updateDoc.info;
        
        console.log('/update: ', updateDoc);

        Routes.connector.upsert(person);
        //Routes.connector.updateChangeSeqid(updateDoc.changeseqid);

        res.contentType('application/json');
        res.send({ route: '/update', doc: updateDoc, status: 'ok'});        
    }

    public changeseqid(req: Request, res: Response, next: NextFunction) {
        console.log('GET /changeseqid:');
        Routes.connector.getChangeSeqId().then((data) => {
            console.log('data: ', data);
            res.contentType('application/json');
            res.send({ route: '/changeseqid', changeseqid: data, status: 'ok'});
        });
    }

    public bulkcreate(req: Request, res: Response, next: NextFunction) {
        let persons: Person[];     
        persons = req.body.array;
        
        Routes.connector.bulkCreate(persons).then(() => {
            res.contentType('application/json');
            res.send({ route: '/bulkupdate', status: 'ok'});        
        });
    }

    public cities(req: Request, res: Response, next: NextFunction) {
        console.log('GET /cities');
        Routes.connector.getCities().then(data => {
            let cities = <string[]> data;
            res.contentType('application/json');
            res.send(cities);
        });
    }

    public changeseqidPost(req: Request, res: Response, next: NextFunction) {
        console.log('POST /changeseq: ', req.body);
        const update = <UpdateChangeSeg> req.body;
        Routes.connector.updateChangeSeqid(update.table, update.changeseqid).then(() => {
            res.contentType('application/json');
            res.send({ route: '/changeseq', status: 'ok'}); 
        }, (err) => {
            console.log(err);
        });
    }


    public error404(req: Request, res: Response, next: NextFunction) {
        res.contentType('application/json');
        res.statusCode = 404;
        res.send({ route: '404', status: 'error'});
    }
    
}