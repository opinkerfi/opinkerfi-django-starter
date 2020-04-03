from .base import *  # noqa
from .base import env

SECRET_KEY = env(
    "DJANGO_SECRET_KEY",
    default="z3ezePHNAUTlzigtZdkgd7nMBxBVpiZkoAFqdU0teAzUMul3LQGVsem3hTKMp91c",
)


# Database
# https://docs.djangoproject.com/en/1.11/ref/settings/#databases

from . import database

DATABASES = {
    'default': database.config()
}

DATABASES["default"]["ATOMIC_REQUESTS"] = True  # noqa F405
DATABASES["default"]["CONN_MAX_AGE"] = env.int("CONN_MAX_AGE", default=60)  # noqa F405
