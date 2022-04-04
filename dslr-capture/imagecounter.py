
class ImageCounter:
    good = 0
    bad = 0

    @property
    def total(self):
        return self.good + self.bad
