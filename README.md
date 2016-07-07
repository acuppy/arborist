# Arborist

## Usage

`Arborist::Migration` is meant to run as a drop-in replacement to
`ActiveRecord::Migration`.  The easiest way to do that is modify your
 migrations to inherit from `Arborist::Migration`

```ruby
class AddAdminToUser < Arborist::Migration
  data do
    # forward
  end

  def change
    add_column :users, :admin, :boolean
  end
end
```

By default `data` takes a forward-only approach and assumes by rolling back
the schema would automatically revert the data migration.  However, you can
declare both `up` and `down` migrations with similar corresponding method options:

```ruby
class AddAdminToUser < Arborist::Migration
  data :up do # => default
    # forward
  end

  data :down do
    # rollback
  end

  def change
    add_column :users, :admin, :boolean
  end
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

  def change
    add_column :users, :admin, :boolean, default: false
  end
end
```

Similar to other uses of `data` additional configuration options can be
passed in following the

### Interchangeable Models

A common 'best-practice' is to use raw SQL instead of `ActiveRecord` backed
classes, which is a totally practical option (see explanation below), but you
lose the power of `ActiveRecord`, *so what if we could use `ActiveRecord` to
support those changes?*

Interchangeable models can be powerful tool when tracking object references.

Instead of using the model directly, set the target model and use `model` in
the data migration:

```ruby
class AddAdminToUser < Arborist::Migration
  model :User

  data do
    model.all do |user|
      user.admin = true
      user.save!
    end
  end
  # ...
end
```

Now, if in a future iteration of the code, you remove the model or change the
name of a model, older migrations will use the more recently defined reference.

```ruby
class AddAdminToUser < ActiveRecord::Migration
  class Data < Arborist::Migration::Base
    model :User => :Person
  end
  # ...
end
```

Similarly, you can do the same for columns:

```ruby
class AddAdminToUser < ActiveRecord::Migration
  class Data < Arborist::Migration::Base
    model :User, :attributes => {
      :firstname => :first_name,
      :lastname  => :last_name
    }
  end
  # ...
end
```

And, they can be used in conjunction with on
e another:

```ruby
class AddAdminToUser < ActiveRecord::Migration
  class Data < Arborist::Migration::Base
    model :User => :Person, :columns => {
      [:User, :firstname] => [:Person, :first_name],
      [:User, :lastname]  => [:Person, :last_name]
    }
  end
  # ...
end
```

If this becomes confusing, that's okay. `Arborist` runs a built in linter
(`Arborist::Migration.lint!`) prior to migrating to confirm that all models
and attribute dependencies *being referenced* are available. If any failure
exists, the migration will fail *prior* to running all the migrations.

### Failure

`Arborist` will suggest a data migration for the model reference, either in the
form of an addition to the offending migration...

Add to migration 'db/migrate/1234567890_add_admin_to_person.rb':

```ruby
class Data < Arborist::Migration::Base
  model :User => '...'
end
```

... or to generate a new data migration to fix the problem:

`$ rails g data_migration:model User`

Which generates:

```ruby
class UpdateReferenceForUserModel < ActiveRecord::Migration
  class Data < Arborist::Migration::Base
    model :User => '...'
  end
end
```

## Testing

By abstracting all larger migration routines to a nested class, we can test
those as Ruby objects.

With `RSpec` we can use a bank of custom matcher:

```rspec
require 'rails_helper'
require_migration 'add_admin_to_user' # Note: Do NOT include the datetime stamp

describe AddAdminToUser::Data do
  # ...
end
```

## Methodology

Data migration in a Rails application can be a serious pain.  Whether you take
the strategy of including the data migration in the schema migrations...

```ruby
class AddAdminToUser < ActiveRecord::Migration
  def change
    # Schema migration
    add_column :users, :admin, :boolean, default: false

    # Data migration
    User.all do |user|
      user.admin = true;
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
gem 'arborist'
```

And then execute:

`$ bundle`

Or install it yourself as:

`$ gem install arborist`

## Contributing

1.  Fork it ( https://github.com/{my-github-username}/arborist/fork )
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request
