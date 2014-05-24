from django.conf.urls import patterns, include, url
from Demo1.views import hello
from Demo1.views import current_datetime
from Demo1.views import hours_ahead
from django.contrib import admin

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'DjangoTest.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    ('^hello/$', hello),
    ('^time/$', current_datetime),
    (r'^time/plus/(\d{1,2})/$', hours_ahead),
)
