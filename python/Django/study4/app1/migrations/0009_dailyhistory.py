# Generated by Django 3.0.3 on 2020-02-20 01:31

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0008_chinaadd'),
    ]

    operations = [
        migrations.CreateModel(
            name='DailyHistory',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('heal', models.IntegerField()),
                ('dead', models.IntegerField()),
                ('nowConfirm', models.IntegerField()),
                ('healRate', models.CharField(max_length=10)),
                ('deadRate', models.CharField(max_length=10)),
                ('type', models.CharField(max_length=10)),
                ('date', models.CharField(max_length=10)),
            ],
        ),
    ]
