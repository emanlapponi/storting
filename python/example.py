import sys

class Example():
    def __init__(self, label, metadata={}, features={}):
        self.label = label
        self.metadata = metadata
        self.features = features

    def string_vector(self):
        """
        Do something smart with selecting features
        from self.features
        """
        pass
    
    def numpy_vector(self):
        """
        Use scikit-learn to return a suitable representation
        for scikit-learn
        """
        pass
