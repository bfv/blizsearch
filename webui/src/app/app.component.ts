import { Component } from '@angular/core';
import { Http, URLSearchParams, RequestOptionsArgs } from '@angular/http';
import { Person } from './person';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app';

  public city: string;
  public lastname: string;
  public persons: Person[];
  public elapsed: number;

  public count: number;

  constructor(private http: Http) {

  }

  public submit() {

    if (this.lastname || this.city) {

      const start = new Date().getTime();

      const searchParams = new URLSearchParams();
      if (this.lastname) {
        searchParams.set('lastname', this.lastname);
      }
      if (this.city) {
        searchParams.set('city', this.city);
      }

      const options: RequestOptionsArgs = { };
      options.search = searchParams;

      this.http.get('http://localhost:4220/search', options).subscribe(
        data => {
          this.elapsed = new Date().getTime() - start;
          this.persons = <Person[]> data.json();
          this.count = this.persons.length;
        }
      );
    }
  }
}
