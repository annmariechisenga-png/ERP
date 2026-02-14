class Employee:
    def __init__(self, name, salary_scale):
        self.name = name
        self.salary_scale = salary_scale
        self.leave_balance = 0
        self.leave_taken = 0

    def accrue_leave(self):
        accrual_rates = {
            "G3": 2, "G2": 2, "G1": 2,  # Division IV
            "LGSS/18": 2.5, "LGSS/17": 2.5, "LGSS/16": 2.5, "LGSS/15": 2.5, "LGSS/14": 2.5, "LGSS/13": 2.5,  # Division III
            "LGSS/12": 3, "LGSS/11": 3, "LGSS/10": 3, "LGSS/09": 3, "LGSS/08": 3,  # Division II
            "LGSS/07": 3.5, "LGSS/06": 3.5, "LGSS/05": 3.5, "LGSS/04": 3.5, "LGSS/03": 3.5, "LGSS/02": 3.5, "LGSS/01": 3.5  # Division I
        }
        self.leave_balance += accrual_rates.get(self.salary_scale, 0)

    def take_leave(self, days):
        if days <= self.leave_balance:
            self.leave_balance -= days
            self.leave_taken += days
        else:
            print(f"{self.name} does not have enough leave days.")

    def carryover(self):
        return self.leave_balance

    def __str__(self):
        return (f"{self.name} ({self.salary_scale}) → "
                f"Balance: {self.leave_balance} days, Taken: {self.leave_taken}, "
                f"Carryover: {self.carryover()} days")
