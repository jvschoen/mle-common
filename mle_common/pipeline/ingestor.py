# This class should ingest a table object
#

from abc import abstractmethod
from mle_common.pipeline.table import Table


class Ingestor:
    def __init__(self, table: Table):
        self.table = table

    @abstractmethod
    def load_df(self):
        pass


class DatabaseIngestor():

    def load_df(self):

