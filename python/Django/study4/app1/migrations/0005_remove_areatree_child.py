# Generated by Django 3.0.3 on 2020-02-17 09:31

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0004_areatree'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='areatree',
            name='child',
        ),
    ]
