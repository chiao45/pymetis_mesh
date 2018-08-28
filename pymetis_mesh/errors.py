"""METIS exceptions

Attributes
----------
:class:`MetisInputError` invalid input
:class:`MetisMemoryError` malloc issues
:class:`MetisError` all other errors
"""


class MetisInputError(AttributeError):
    pass


class MetisMemoryError(MemoryError):
    pass


class MetisError(RuntimeError):
    pass
