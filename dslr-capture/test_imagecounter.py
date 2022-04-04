#!/usr/bin/env python3
from imagecounter import ImageCounter
import unittest

class TestImageCounter(unittest.TestCase):
    def setUp(self):
        self.counter = ImageCounter()

    def testDefaults(self):
        ctr = self.counter
        self.assertEqual(ctr.good, 0)
        self.assertEqual(ctr.bad, 0)
        self.assertEqual(ctr.total, 0)
    
    def testTotalProperty(self):
        ctr = self.counter
        ctr.good += 1
        self.assertEqual(ctr.total, 1)
        ctr.bad += 1
        self.assertEqual(ctr.total, 2)

if __name__ == '__main__':
    unittest.main()

