# Openshift quickstart: Django

This is a [Django](http://www.djangoproject.com) project that you can use as the starting point to develop your own and deploy it on an [OpenShift](https://github.com/openshift/origin) cluster.

The steps in this document assume that you have access to an OpenShift deployment that you can deploy applications on.

## What has been done for you

This is a minimal Django 2.0 project. It was created with these steps:

1. Create a virtualenv
2. Manually install Django and other dependencies
3. `pip freeze > requirements.txt`
4. `django-admin startproject project .`
3. Update `project/production.py` and `project/local.py` to configure `SECRET_KEY`, `DATABASE` and `STATIC_ROOT` entries
4. `./manage.py startapp welcome`, to create the welcome page's app

From this initial state you can:
* create new Django apps
* remove the `welcome` app
* rename the Django project
* update settings to suit your needs
* install more Python libraries and add them to the `requirements/base.txt` file

## Special files in this repository

Apart from the regular files created by Django (`project/*`, `welcome/*`, `manage.py`), this repository contains:

```shell
openshift/         - OpenShift-specific files
├── scripts        - helper scripts
└── templates      - application templates

requirements.txt   - list of dependencies
```

## Warnings

Please be sure to read the following warnings and considerations before running this code on your local workstation, shared systems, or production environments.

### Database configuration

The sample application code and templates in this repository contain database connection settings and credentials that rely on being able to use sqlite.

### Automatic test execution

The sample application code and templates in this repository contain scripts that automatically execute tests via the postCommit hook.  These tests assume that they are being executed against a local test sqlite database. If alternate database credentials are supplied to the build, the tests could make undesirable changes to that database.

## Local development

To run this project in your development machine, follow these steps:

1. (optional) Create and activate a [virtualenv](https://virtualenv.pypa.io/) (you may want to use [virtualenvwrapper](http://virtualenvwrapper.readthedocs.org/)).

2. Ensure that the executable `pg_config` is available on your machine. You can check this using `which pg_config`. If not, install the dependency with one of the following.
  - macOS: `brew install postgresql` using [Homebrew](https://brew.sh/)
  - Ubuntu: `sudo apt-get install libpq-dev`
  - [Others](https://stackoverflow.com/a/12037133/8122577)

3. Fork this repo and clone your fork:

`git clone https://gitlab.com/opinkerfi-opensource/opinkerfi-django-starter.git`

4. Install dependencies:

`pip install -r requirements/local.txt`

5. Set environment for local development, so settings are loaded from project/local.py and create a development database:

```shell
export DJANGO_SETTINGS_MODULE=project.local
./manage.py migrate
```

6. If everything is alright, you should be able to start the Django development server:

`./manage.py runserver`

7. Open your browser and go to http://127.0.0.1:8000, you will be greeted with a welcome page.

## Deploying to OpenShift

To follow the next steps, you need to be logged in to an OpenShift cluster and have an OpenShift project where you can work on.

### Using an application template

The directory `openshift/templates/` contains OpenShift application templates that you can add to your OpenShift project with:

```shell
oc create -f openshift/templates/opinkerfi-django-starter.json
```

After adding your templates, you can go to your OpenShift web console, browse to your project and click the create button. Create a new app from one of the templates that you have just added.

Adjust the parameter values to suit your configuration. Most times you can just accept the default values, however you will probably want to set the `GIT_REPOSITORY` parameter to point to your fork and the `DATABASE_*` parameters to match your database configuration.

Alternatively, you can use the command line to create your new app, assuming your OpenShift deployment has the default set of ImageStreams defined.  Instructions for installing the default ImageStreams are available [here](https://docs.okd.io/latest/install_config/imagestreams_templates.html).  If you are defining the set of ImageStreams now, remember to pass in the proper cluster-admin credentials and to create the ImageStreams in the 'openshift' namespace:

```shell
oc new-app openshift/templates/opinkerfi-django-starter.json -p SOURCE_REPOSITORY_URL=<your repository location>
```

Your application will be built and deployed automatically. If that doesn't happen, you can debug your build:

```shell
oc get builds
# take build name from the command above
oc logs build/<build-name>
```

And you can see information about your deployment too:

```shell
oc describe dc/django-example
```

In the web console, the overview tab shows you a service, by default called "django-example", that encapsulates all pods running your Django application. You can access your application by browsing to the service's IP address and port.  You can determine these by running

```shell
oc get svc
```

## Logs

By default your Django application is served with gunicorn and configured to output its access log to stderr.
You can look at the combined stdout and stderr of a given pod with this command:

```shell
oc get pods         # list all pods in your project
oc logs <pod-name>
```

This can be useful to observe the correct functioning of your application.

## Special environment variables

### APP_CONFIG

You can fine tune the gunicorn configuration through the environment variable `APP_CONFIG` that, when set, should point to a config file as documented [here](http://docs.gunicorn.org/en/latest/settings.html).

### DJANGO_SECRET_KEY

When using one of the templates provided in this repository, this environment variable has its value automatically generated. For security purposes, make sure to set this to a random string as documented [here](https://docs.djangoproject.com/en/1.8/ref/settings/#std:setting-SECRET_KEY).

## One-off command execution

At times you might want to manually execute some command in the context of a running application in OpenShift.
You can drop into a Python shell for debugging, create a new user for the Django Admin interface, or perform any other task.

You can do all that by using regular CLI commands from OpenShift.
To make it a little more convenient, you can use the script `openshift/scripts/run-in-container.sh` that wraps some calls to `oc`.
In the future, the `oc` CLI tool might incorporate changes
that make this script obsolete.

Here is how you would run a command in a pod specified by label:

1. Inspect the output of the command below to find the name of a pod that matches a given label:

```shell
oc get pods -l <your-label-selector>
```

2. Open a shell in the pod of your choice. Because of how the images produced
  with CentOS and RHEL work currently, we need to wrap commands with `bash` to
  enable any Software Collections that may be used (done automatically inside
  every bash shell).

```shell
oc exec -p <pod-name> -it -- bash
```

3. Finally, execute any command that you need and exit the shell.

Related GitHub issues:
1. https://github.com/GoogleCloudPlatform/kubernetes/issues/8876
2. https://github.com/openshift/origin/issues/2001


The wrapper script combines the steps above into one. You can use it like this:

```shell
./run-in-container.sh "./manage.py migrate"         # manually migrate the database
                                                    # (done for you as part of the deployment process)
./run-in-container.sh "./manage.py createsuperuser" # create a user to access Django Admin
./run-in-container.sh "./manage.py shell"           # open a Python shell in the context of your app
```

If your Django pods are labeled with a name other than "django-psql-persistent", you will need to edit the run-in-container.sh file

## Data persistence

You should add a properly configured database server or ask your OpenShift administrator to add one for you. Then use `oc env` to update the `DATABASE_*` environment variables in your DeploymentConfig to match your database settings.  The template will generate values for these as well.

Redeploy your application to have your changes applied, and open the welcome page again to make sure your application is successfully connected to the database server.

## Looking for help

If you get stuck at some point, or think that this document needs further details or clarification, you can give feedback and look for help using the channels mentioned in [the OKD repo](https://github.com/openshift/origin), or by filing an issue.

## References

This project is heavily inspired by:

* [Openshift quickstart: Django](https://github.com/sclorg/django-ex)
* [Cookiecutter Django](https://github.com/pydanny/cookiecutter-django)

## License

This code is dedicated to the public domain to the maximum extent permitted by applicable law, pursuant to [CC0](http://creativecommons.org/publicdomain/zero/1.0/).
