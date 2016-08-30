# Strava Best Efforts

This small app fetches Strava running best efforts using Strava API,
then fires up a webpage to visualize the best efforts data,
so that some analysis can be performed on athletes' best efforts data,
like half marathon PB progression, fastest shoes for a 10K race, etc.

**DEMO HERE**: [Strava Best Efforts - Yi Zeng][Running Best Efforts]

![Demo Screenshot][Demo Screenshot]

Ideally in the future, this app can be setup and served in a similar fashion as [VeloViewer][VeloViewer],
with front-end UI, back-end DB and a bacground process:

1. (Users) Open up this web application and see 'Connect with Strava' button.
2. (Users) Click the button and go through Strava authentication process.
3. (Users) Get redirected back to this application.
4. (Server) Save all authentication information to database on the server.
5. (Background process) Run on the server and get this athlete's data using Strava API.
6. (Users) See a detailed user interface for analyzing their best efforts data.
7. (Users) Visit the site anytime later and view all data (which are saved on the server).

Currently the app only contains a background fetching process and a front-end visualizer,
as it was all started few as Ruby scripts I wrote to fetch my own Strava Best Efforts.

## Documentation

### What are 'Best Efforts'?

Quoting from [Strava Support][Strava Support]:

> Estimated Best Efforts are automatically calculated using your GPS-based running activity,
  and reflect your fastest times for benchmark distances such as 1 mile, 5km, 10km, and half marathon.
  Strava can find your best effort at any point in each running activity.
  We do not require that a best effort starts at a mile split.

![Side by side Best Efforts][Side by side Best Efforts]
![Strava Best Efforts][Strava Best Efforts]

### How does this program work?

1. In fetching mode (`ruby app.rb --fetch`),
   the program calls `list_athlete_activities` from [Strava Ruby API][Strava Ruby API] to get all activities of current athlete.
   It tries to get 200 activities per page, maximum of 100 pages,
   which can hold a total number of 20000 activities. (Strava won't allow more than 200 activities per page.)
2. Then it loops through all those activities to find out all running activities that have achievement items,
   and saves the activity ids to a result set.
3. For each activity id in the result set, call Strava Ruby API `retrieve_an_activity` method
   to get detailed information about this activity.
4. Then calling `ruby app.rb --serve` command (the serving mode) will serve a web application with JSON data just fetched
   and provide a visualized way for analysis.

### How to run?

#### Setup `config.yml`

**Get Strava Access Token**

All calls to the Strava API require an access_token defining the athlete and application making the call.
Any registered Strava user can obtain an access_token by first creating an application at <https://www.strava.com/settings/api>.

**Set directory for result JSON files**

`dir_result` sets the directory where result JSON file should be saved.
It defaults to `history/` folder where `app.rb` file is.
Every successful run should generate a new file under such folder.

#### Install Dependencies

At this stage, the app has only Ruby Gem '[strava-api-v3][strava-api-v3]' as a dependency.

    gem install 'strava-api-v3'

Or use [Ruby Bundler][Ruby Bundler] if you prefer:

    gem install bundler # if you haven't got bundler installed yet.
    bundle install

#### Run Program

**Fetch mode** (It fetches the athlete and best efforts data):

    ruby app.rb -f

**Serve mode** (It loads up the JSON files and server at <http://localhost:5050>):

    ruby app.rb -s

### What does JSON result look like?

Here is an example JSON result file for my Strava Activity [Southern Lakes Half Marathon 2016][Southern Lakes Half Marathon 2016]:

    {"pr_rank":1,"activity_id":690235515,"activity_name":"Southern Lakes Half Marathon 2016","distance":21138.8,"moving_time":5645,"elapsed_time":5631,"total_elevation_gain":16.0,"start_date":"2016-04-02T08:59:58Z","start_date_local":"2016-04-02T08:59:50Z","start_latitude":-44.86,"start_longitude":169.03,"athlete_count":8,"trainer":false,"commute":false,"manual":false,"private":false,"average_speed":3.745,"max_speed":5.2,"has_heartrate":true,"elev_high":500.0,"elev_low":282.2,"workout_type":1,"description":"(Uploaded via API. Gear name: ASICS DS Trainer 19 (Blue). Device name: Garmin Forerunner 235. Workout Type: 1)","calories":1590.9,"device_name":null,"location_country":"New Zealand","average_heartrate":169.2,"max_heartrate":180.0,"gear_name":"ASICS DS Trainer 19 (Blue)","name":"Half-Marathon"}

### How JSON results are used?

[Strava Best Efforts - Yi Zeng][Running Best Efforts] page is a demo on how JSON results are used.
It loads up the JSON file created using this program,
then analyze the data and output into a table.

[Demo Screenshot]: /assets/img/demo-screenshot.png
[VeloViewer]: https://veloviewer.com/
[Strava Support]: https://support.strava.com/hc/en-us/articles/216917127-Estimated-Best-Efforts-for-Running
[Side by side Best Efforts]: https://support.strava.com/attachments/token/B2NpmmMYGEVEzCJn7ZjoMFtsk/?name=Side+by+Side-+Best+Effort.png
[Strava Best Efforts]: https://support.strava.com/attachments/token/UJw9NjMB5AZSqRm8sst8kUqUy/?name=activity+-+Best+Effort.png
[Strava Ruby API]: https://github.com/jaredholdcroft/strava-api-v3
[strava-api-v3]: https://rubygems.org/gems/strava-api-v3
[Ruby Bundler]: http://bundler.io/
[Southern Lakes Half Marathon 2016]: https://www.strava.com/activities/690235515/overview
[Running Best Efforts]: http://yizeng.me/running/best-efforts/
