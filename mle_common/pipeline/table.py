# This class should define a table
# A table should hold information relevant for ingestion

class Table:
    def __init__(self):
        break

class DatabaseTable(Table):
    def __init__(self, database=None, schema=None, table=None):
        """Expected namespace args or tablename
        Example:
        'database', 'schema', 'tablename' makes the table name ->
        database.schema.tablename
        """
        self.database = database
        self.schema = schema
        self.table = table


class FileTable(Table):
    def __init__(self, filepath):
        """Expected namespace args or tablename
        Example:
        'database', 'schema', 'tablename' makes the table name ->
        database.schema.tablename
        """

        self.filepath = filepath