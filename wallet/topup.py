from decimal import Decimal
from dataclasses import dataclass


@dataclass
class TopupTask:
    account_name: str
    amount: Decimal
