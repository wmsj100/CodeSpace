from django.db import models

class ChinaDayList(models.Model):
    confirm = models.IntegerField()
    suspect = models.IntegerField()
    dead = models.IntegerField()
    heal = models.IntegerField()
    nowConfirm = models.IntegerField()
    nowSevere = models.IntegerField()
    deadRate = models.CharField(max_length=20)
    healRate = models.CharField(max_length=20)
    date = models.CharField(max_length=20)

    def __str__(self):
        return self.date

class ChinaDayAddList(models.Model):
    confirm = models.IntegerField()
    suspect = models.IntegerField()
    dead = models.IntegerField()
    heal = models.IntegerField()
    deadRate = models.CharField(max_length=20)
    healRate = models.CharField(max_length=20)
    date = models.CharField(max_length=20)

    def __str__(self):
        return self.date

class DailyNewAddHistory(models.Model):
    date = models.CharField(max_length=20)
    hubei = models.IntegerField()
    country = models.IntegerField()
    notHubei = models.IntegerField()

    def __str__(self):
        return self.date

class DailyDeadRateHistory(models.Model):
    date = models.CharField(max_length=20)
    hubeiRate = models.CharField(max_length=20)
    notHubeiRate = models.CharField(max_length=20)
    countryRate = models.CharField(max_length=20)

    def __str__(self):
        return self.date

class DailyHealRateHistory(models.Model):
    date = models.CharField(max_length=20)
    hubeiRate = models.CharField(max_length=20)
    notHubeiRate = models.CharField(max_length=20)
    countryRate = models.CharField(max_length=20)

    def __str__(self):
        return self.date

class AreaTree(models.Model):
    name = models.CharField(max_length=20)
    date = models.CharField(max_length=20)
    confirm = models.IntegerField()
    totalConfirm = models.IntegerField()
    totalSuspect = models.IntegerField()
    totalDead = models.IntegerField()
    totalHeal = models.IntegerField()
    deadRate = models.CharField(max_length=20)
    healRate = models.CharField(max_length=20)
    parent = models.CharField(max_length=20, default='')
    type = models.CharField(max_length=10, default='')

    def __str__(self):
        return self.name

class ChinaAdd(models.Model):
    confirm = models.IntegerField()
    heal = models.IntegerField()
    suspect = models.IntegerField()
    dead = models.IntegerField()
    nowSevere = models.IntegerField()
    nowConfirm = models.IntegerField()
    type = models.CharField(max_length=10)
    date = models.CharField(max_length=10)

    def __str__(self):
        return self.date

class DailyHistory(models.Model):
    heal = models.IntegerField()
    dead = models.IntegerField()
    nowConfirm = models.IntegerField()
    healRate = models.CharField(max_length=10)
    deadRate = models.CharField(max_length=10)
    type = models.CharField(max_length=10)
    date = models.CharField(max_length=10)

    def __str__(self):
        return self.date

class ArticleList(models.Model):
    title = models.CharField(max_length=50)
    desc = models.TextField()
    url = models.URLField()
    media = models.CharField(max_length=50)
    cmsId = models.CharField(max_length=50)
    source = models.CharField(max_length=20)
    publish_time = models.CharField(max_length=20)
    can_use = models.IntegerField()

    def __str__(self):
        return self.title

class WuhanDayList(models.Model):
    confirmAdd = models.IntegerField()
    date = models.CharField(max_length=10)
    type = models.CharField(max_length=20)

    def __str__(self):
        return self.type
