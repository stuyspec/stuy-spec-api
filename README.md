![alt text](https://i.imgur.com/uti8BnI.png)
# Stuyvesant Spectator API

This is the official API for the Stuyvesant Spectator. Currently it is used as a backing service
for the Spectator website, but there are plans in the future to publish it as a public API.

The application is a Rails application, with a Postgres database. Everything is published as JSON
(in either camelCase or snake_case, using [Olive Branch](https://github.com/vigetlabs/olive_branch)). It is deployed on AWS using Elastic Beanstalk

## Setting Up
1. Clone the repo (`git clone https://github.com/stuyspec/stuy-spec-api.git`)
2. Install Ruby. We highly suggest rbenv or rvm
3. Install Rails 5.1
4. Install PostgreSQL (`brew install postgres` on Mac OS)
5. Install Docker
6. Run `docker-compose build`
7. Run `docker-compose up`. If you get an error saying it can't connect to db, try stopping
and rerunning.
8. In a separate terminal instance, run `docker-compose run web rake db:create`. If there are a bunch of errors about being unable to connect to TCP/IP at 5432, just check the top of those errors to see if something like `Created database stuy-spec-api_development` was created. If so, then ignore the errors.
9. Run `docker-compose run web db:migrate db:seed`
10. To start the server, run `docker-compose run web rails server`.

## Troubleshooting

### Server exited at `docker-compose up`
Check the last few lines of the server log in your shell.
1. A server is already running.
```
web_1  | A server is already running. Check /stuy-spec-api/tmp/pids/server.pid.
web_1  | => Booting Puma
web_1  | => Rails 5.1.2 application starting in development on http://0.0.0.0:3000
web_1  | => Run `rails server -h` for more startup options
web_1  | Exiting
stuyspecapi_web_1 exited with code 1
```
To solve this problem, we need to remove the `server.pid` file. Navigate to the stuy-spec-api directory and run:
```
rm tmp/pids/server.pid
```

### Connection refused at `docker-compose run web ...`
```
could not connect to server: Connection refused
	Is the server running on host "localhost" (127.0.0.1) and accepting
	TCP/IP connections on port 5432?
```
You might have a server already running that has not shut down correctly. Run `brew services stop postgresql`

In general, if you run into this error, the command may have already worked. Look at the top of the error. If you tried to run `docker-compose run web rails db:create` and, on top of the Connection refusal, it says "Created database...", the command worked. It may have interrupted the `db:migrate`, so run `docker-compose run web rails db:migrate` as an individual function separated from the `db:create`.

### Database drop/reset fails
```
Couldn't drop database 'stuy-spec-api_development'
rails aborted!
ActiveRecord::StatementInvalid: PG::ObjectInUse: ERROR:  database "stuy-spec-api_development" is being accessed by other users
DETAIL:  There are {SOME_NUMBER} other sessions using the database.
```
There is a rake task for deleting these sessions in `lib/tasks/kill_postgres_connections.rake`. To run the task, do
```sh
docker-compose run web rake kill_postgres_connections
```
This should kill related postgres connections, and database drop/reset should now work.

If dropping the database still does not work, use the initializer at `config/initializers/postgresql_database_tasks.rb` by adding an environment option to the rake task like so:
```sh
docker-compose run web rake environment db:drop
```

