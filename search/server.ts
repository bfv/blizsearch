
import * as express from "express";
import * as bodyParser from 'body-parser';
import * as cors from 'cors';
import { Routes } from './routes';
import { DbConnector } from './db/dbconnector';
import { MongoConnector } from './db/mongoconnector';


export class Server {

    public app: express.Application;
    private dbconnector: DbConnector;
    private jsonParser;
    private router: express.Router;

    public static bootstrap(): Server {
        return new Server();
    } 

    constructor() {
        this.app = express();
        this.config();
        this.routes();
        this.app.listen(4220, () => {
            console.log('listening on port 4220');
        });
    }

    private config() {

        this.router = express.Router();

        // setup CORS
        const options: cors.CorsOptions = {
            // allowedHeaders: ["Origin", "X-Requested-With", "Content-Type", "Accept", "X-Access-Token"],
            allowedHeaders: ["Origin", "Content-Type", "Accept"],
            credentials: true,
            methods: "GET,HEAD,OPTIONS,PUT,PATCH,POST,DELETE",
            origin: "http://localhost:4230",
            preflightContinue: false
        };
        this.router.use(cors(options));
        
        // enable parsing json out of the HTTP body
        this.jsonParser = bodyParser.json();

        // connect the db
        this.dbconnector = new MongoConnector();
        this.dbconnector.init().then(result => {
            console.log('database connected');
        }).catch(err =>  {
            console.log('error connecting database: ', err);
            console.log('exiting...');
            process.exit(1); 
        });
    }

    private routes() {

        const routes: Routes = new Routes(this.dbconnector);
        this.router.get('/', routes.home);
        this.router.get('/search', routes.search);
        this.router.get('/changeseqid', routes.changeseqid);
        this.router.get('/cities', routes.cities);
        this.router.post('/update', this.jsonParser, routes.update);
        this.router.post('/bulkcreate', this.jsonParser, routes.bulkcreate);
        this.router.post('/changeseq', this.jsonParser, routes.changeseqidPost);
        this.router.get('*', routes.error404);  // catch all

        this.app.use(this.router);
    }
}