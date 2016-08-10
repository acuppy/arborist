# Arborist

## Usage

`Arborist::Migration` is meant to run as a drop-in replacement for
`ActiveRecord::Migration`.  The easiest way to do that is modify your
 migrations to inherit from `Arborist::Migration`

```ruby
class AddAdminToUser < Arborist::Migration
  data do
    # forward
  end
  # ...
end
```

By default `data` takes a forward-only approach and assumes by rolling back
the schema would automatically revert the data migration.  However, you can
declare both `up` and `down` migrations with similar corresponding method
options:

```ruby
class AddAdminToUser < Arborist::Migration
  data :up do # => default
    # forward
  end

  data :down do
    # rollback
  end
  # ...
end
```

Optionally, pass a migration message:

```ruby
class AddAdminToUser < ActiveRecord::Migration
  data say: 'Updating admin flag' do
    # ...
  end
  # ...
end
```

### Helpers

Although all `ActiveRecord::Migration` methods are supported (e.g., `up`, `down`
  , `change`), there are a set of helpers to define one action against another.

```ruby
class AddAdminToUser < Arborist::Migration
  data do # :up
    # data only adjustments
  end

  schema do # :change
    add_column :users, :admin, :boolean
  end
end
```

For more complex data migrations you can provide a class.  The only
expectation is that the class being referenced includes a public `call`
method. And, like other previous implementations, you can provide options such
as `say`, `up` and `down` (to name a few).

```ruby
class AddAdminToUser < Arborist::Migration
  class UpdateAdminFlag
    def call
      # custom migration ...
    end
  end

  data use: UpdateAdminFlag

  schema do
    add_column :users, :admin, :boolean, default: false
  end
end
```

### Interchangeable Models

A common 'best-practice' is to use raw SQL instead of `ActiveRecord` backed
classes, which is a totally practical option (see explanation below), but you lose the power of `ActiveRecord`, *what if we could use `ActiveRecord` to support those changes?*

Interchangeable models can be powerful tool when tracking object references.

Instead of using the model directly, set the target model and use `model` in
the data migration:

```ruby
class AddAdminToUser < Arborist::Migration
  model :User

  data do
    model.find_each do |user|
      user.admin = true
      user.save!
    end
  end
  # ...
end
```

Further, if you need to reference multiple models, you can do so by setting a
method reference for each:

```ruby
class AddAdminToUser < Arborist::Migration
  model :User,    as: :user
  model :Company, as: :company

  data do
    # user.all...
    # company.all...
  end
  # ...
end
```

`Arborist` runs a built in linter (`Arborist::Migration.lint!`) prior to
migrating to confirm that all models and attribute dependencies *being
referenced* are available. If any failure exists, the migration will fail
*prior* to running all the migrations.

## Methodology

Data migration in a Rails application can be a serious pain.  Whether you take
the strategy of including the data migration in the schema migrations...

```ruby
class AddAdminToUser < ActiveRecord::Migration
  def change
    # Schema migration
    add_column :users, :admin, :boolean, default: false

    # Data migration
    User.all.each do |user|
      user.admin = true
      user.save!
    end
  end
end
```

Which at the time of generating the migration, works without issue; however,
down the line, we rename the `User` model and neglect to update this migration.

In the future, when we run the entire set of migration (vs.
  `rake db:schema:load`) and the `User` model is missing, the migrations
  explode - this sucks.

### Common Solutions

*Temporary Models*

```ruby
class AddAdminToUser < ActiveRecord::Migration
  # Temporary class
  class User < ActiveRecord::Base
  end
  # ...
end
```

And although this is a solution, this course of action results in duplicating
the interface.  Additional issues can present themselves, because the `User`
model is under the `AddAdminToUser` namespace (`AddAdminToUser::User`), which
will present issues when setting a polymorphic association or following an
Single Table Inheritance (STI) model.

### Raw SQL

A Rails independent strategy, you can use straight SQL.  Then ActiveRecord
models are not needed, and the presence (or lack) of the model is irrelevant.

```ruby
class AddAdminToUser < ActiveRecord::Migration
  def change
    # Schema migration
    add_column :users, :admin, :boolean, default: false

    # Data migration in raw SQL
    execute <<-SQL
      UPDATE `users` SET `users`.`admin` = true
    SQL
  end
end
```

As pointed out by many, this doesn't have many downsides, other than database
syntax differences.

### Rake tasks

If entirely opposed to including data migrations in the ActiveRecord migrations
themselves (all examples above), then it's common to create a one off rake
tasks, which would be run directly on the instance.

`$ rake data:add_admin_flag_to_current_users`

But it requires the command is run on all application instances and following
the appropriate migration (i.e. `AddAdminToUser`); which could be done via
the deployment hooks.  However, you would be breaking the isolation of your
migrations (within `db/migrate`) and polluting `lib/tasks/` with one-off rake
tasks; requiring cleanup.

Other issues: testing a rake task can be challenging; and, in essence we're
exposing a production available routine that could cause serious issues, such
as adding the admin flag to all users.

Wouldn't it be nice if you could:

*  Run data migrations side by side with the corresponding schema migration(s);
*  Test the data migration routine;
*  Optionally disable data migrations on an environment, such as production?

Sure, it would.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arborist-rails'
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request
