# Generated by Django 3.0.3 on 2020-02-16 11:51

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='ChinaDayAddList',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('confirm', models.IntegerField()),
                ('suspect', models.IntegerField()),
                ('dead', models.IntegerField()),
                ('heal', models.IntegerField()),
                ('deadRate', models.CharField(max_length=20)),
                ('healRate', models.CharField(max_length=20)),
                ('date', models.CharField(max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='ChinaDayList',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('confirm', models.IntegerField()),
                ('suspect', models.IntegerField()),
                ('dead', models.IntegerField()),
                ('heal', models.IntegerField()),
                ('nowConfirm', models.IntegerField()),
                ('nowSevere', models.IntegerField()),
                ('deadRate', models.CharField(max_length=20)),
                ('healRate', models.CharField(max_length=20)),
                ('date', models.CharField(max_length=20)),
            ],
        ),
    ]
