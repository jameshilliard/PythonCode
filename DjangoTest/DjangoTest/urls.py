from django.conf.urls import patterns, include, url

from django.contrib import admin
from Demo1.views import hello
from Demo1.views import current_datetime
from Demo1.views import hours_ahead
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'DjangoTest.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    url('^hello/$', hello),
    url('^time/$', current_datetime),
    url('^another-time-page/$', current_datetime),
    url(r'^time/plus/(\d{1,2})/$', hours_ahead),
)
