References
===========================

Docker Commands
---------------

[Reference to rebuild Rails 7 application](https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/rails/
)

To generate a Rails skeleton:

```bash
docker compose run --no-deps web rails new . --force --database=postgresql
```

To boot the app:

```bash
docker compose up
```

To create a database:

```bash
docker compose run web rake db:create
```

To stop the app:

```bash
docker compose down
```

To rebuild the app, after a gemfile/compose update:

```bash
docker compose run web bundle install # Will regen Gemfile.lock
docker compose up --build
```

Console:

```bash
docker compose run web rails console
```

Routes:

```bash
docker compose run web rails routes
```

Hotwire References
------------------

https://hotwired.dev

https://github.com/hotwired/turbo-rails

https://bhserna.com/inline-crud-hotwire.html

https://github.com/bhserna/inline_crud_hotwire/tree/main

https://github.com/thoughtbot/hotwire-example-template/tree/hotwire-example-inline-edit

https://gorails.com/episodes/inline-editing-turbo-frames

Other References
----------------

https://web-crunch.com/posts/how-to-use-formbuilder-in-ruby-on-rails
