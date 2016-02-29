## Uptime Checker

Check if your sites are online for $7/mo.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://www.heroku.com/deploy/?template=https://github.com/fnando/uptime_checker)

## Configuration

1. Fork this repository
2. Create a branch from `master`.
3. Create the `checkers.yml` file with all your checkers and commit your changes.
4. To keep up with `master`, switch to `master` and run `git pull`. Then switch to your branch and run `git rebase master`. This assumes you didn't touch any of the files, so you won't have any merging issues.

### Environment variables

You can configure some options; just define the following environment variables.

- `LOCALE`: the locale. Defaults to `en`. Check available languages at https://github.com/fnando/uptime_checker/tree/master/lib/uptime_checker/locales
- `TIMEZONE`: the timezone. Defaults to `Etc/UTC`.
- `INTERVAL`: the number of seconds between each verification. Defaults to `30`.

### Defining your checkers

You only have to create a `checkers.yml` file containing all your checkers. Here's an example:

```yaml
# these are the default notifications
notify: &notify
  - stdout: ~
  - email: john@example.com
  - slack: "#core"
  - telegram: 12345678
  - hipchat: 456789
  - twitter: johndoe

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200

  - name: Other site
    url: http://sub.example.com
    notify: *notify
    status: 200
    body: My Other Site
```

You can configure the file location by setting the `CONFIG_FILE` environment variable.

Notice that you can have multiple notifications for the same notifier. Say you also want to send e-mail notification to `jane@example.com`.

```yaml
# these are the default notifications
notify: &notify
  - email: john@example.com
  - email: jane@example.com

# ...
```

For more information about the notifiers, keep reading this README.

#### Failures threshold

You can set the minimum number of failures before triggering the notification. By default you'll be notified every time a check fails. 

The following example will send notifications only when check fails three times.

```yaml
checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    min_failures: 3
```

### Deployment

## Deploying to a VPS

You can deploy uptime_checker to a VPS. If you know how to deploy a Rails application, you won't have any issues deploying uptime_checker.

If you don't, instructions to come. Use Heroku in the meantime.

## Deploying to Heroku

First, clone this repository.

```
git clone https://github.com/fnando/uptime_checker.git
```

Create a new branch. This is required so that you can create your configuration file.

```
git checkout -b mybranch
```

Copy the configuration file and commit it.

```
cp checkers.yml.sample checkers.yml
```

Change the configuration file and commit it.

```
git add .
git commit -a -m "Adding configuration."
```

Now, configure Heroku. Create a new app for this.

```
heroku create
```

You'll also need a Redis instance.

```
heroku addons:create heroku-redis
```

If you're going to send e-mail notification, you'll need Sendgrid as well.

```
heroku addons:create sendgrid:starter
```

Time to deploy:

```
git push heroku mybranch:master
```

Scale up the uptime checker worker:

```
heroku ps:scale worker=1
```

To make your worker run 24/7 (will cost you $7/month):

```
heroku dyno:type worker=hobby
```

To upgrade your branch to the latest version you have to fetch `master`'s changes and rebase onto `mybranch`.

```
git checkout master
git pull
git checkout mybranch
git rebase master
```

After doing the upgrade, deploy it with `git push heroku mybranch:master -f`.

## Notifiers

### Telegram

1. Create a bot. The returned API token must be defined as `TELEGRAM_API_TOKEN` environment variable.
2. Create a new group.
3. Add bot to the group you just created.
4. Go to @BotFather and `/setprivacy` to `enabled`. You also have to `/setjoingroups` to `disabled`.
5. Go to the group you created and send a message to the bot; use something like `@YouBotName hello`.
6. Run `ruby setup/telegram.rb` locally to get the channel id. You may need to install the dependencies with `bundle install` before doing it so.
7. Set the notification as `telegram: <chat id>`. Sometimes id can be a negative number and this is important.

Example:

```yaml
# these are the default notifications
notify: &notify
  - telegram: 12345

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Telegram Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/telegram.png)

### E-mail

**Note:** Currently only SendGrid is supported.

1. Set your username as `SENDGRID_USERNAME` environment variable.
2. Set your password as `SENDGRID_PASSWORD` environment variable.
3. Set the notification as `email: <email address>`.

Example: 

```yaml
# these are the default notifications
notify: &notify
  - email: john@example.com

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Email Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/email.png)

### Twitter

1. Create an user for your bot.
2. Follow your bot, and make your bot follow you.
3. Create a new Twitter application under your bot's account at https://apps.twitter.com/app/new
4. Go to "Keys and Access Tokens" and create a new access token.
5. Set `TWITTER_CONSUMER_KEY`, `TWITTER_CONSUMER_SECRET`, `TWITTER_ACCESS_TOKEN` and `TWITTER_ACCESS_SECRET` environment variables, all available under "Keys and Access Token".
6. Set the notification as `twitter: <username>`.

Example:

```yaml
# these are the default notifications
notify: &notify
  - twitter: johndoe

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Twitter Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/twitter.png)

### Slack

1. Create a new bot user at https://my.slack.com/services/new/bot
2. Set the API token as the `SLACK_API_TOKEN` environment variable.
3. Set the channel name as `slack: "#channel"`.

```yaml
# these are the default notifications
notify: &notify
  - slack: "#core"

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Slack Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/slack.png)

### Campfire

1. Create a new bot user.
2. Logged in as the bot user, go to `https://<your subdomain>.campfirenow.com/member/edit` to get the API token, that must be set as `CAMPFIRE_API_TOKEN`, together with the `CAMPFIRE_SUBDOMAIN`.
3. Set the notification as `campfire: <room id>`.

```yaml
# these are the default notifications
notify: &notify
  - campfire: 123456

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Campfire Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/campfire.png)

### Pushover

To be notified through iOS/Android push notifications, you can use Pushover ($5 for a lifetime license). You can also buy a lifetime license for desktop notifications (or use [Noti](https://notiapp.com) instead).

1. Create a new application at https://pushover.net/apps/build
2. Set the API token as the `PUSHOVER_APPLICATION_TOKEN` environment variable.
3. Set the notification as `pushover: <user token>`.

To avoid committing your user token, you can set it as an environment variable (e.g. `PUSHOVER_JOHN`), and then use eRb code like the following:

```yaml
# these are the default notifications
notify: &notify
  - pushover: <%= ENV["PUSHOVER_JOHN"] %>

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Pushover Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/pushover.png)

### Noti

1. Create a new application at https://notiapp.com/apps/new
2. Set the API as the `NOTI_API_TOKEN` environment variable.
3. Run `ruby setup/noti.rb` locally to get your user token. You may need to install the dependencies with `bundle install` before doing it so.
4. Set the notification as `noti: <user token>`

To avoid committing your user token, you can set it as an environment variable (e.g. `NOTI_JOHN`), and then use eRb code like the following:

```yaml
# these are the default notifications
notify: &notify
  - noti: <%= ENV["NOTI_JOHN"] %>

checks:
  - name: My Site
    url: http://example.com
    notify: *notify
    status: 200
```

![Noti Notifications](https://raw.githubusercontent.com/fnando/uptime_checker/master/screenshots/noti.png)
