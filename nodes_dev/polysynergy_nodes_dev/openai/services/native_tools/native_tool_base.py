from typing import Protocol, runtime_checkable


@runtime_checkable
class NativeToolBase(Protocol):
    """Marker interface"""
    pass