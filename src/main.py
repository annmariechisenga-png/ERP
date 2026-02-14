from employee import Employee

alice = Employee("Alice", "LGSS/12")  # Division II
alice.accrue_leave()  # Month 1
alice.accrue_leave()  # Month 2
alice.take_leave(2)   # Took 2 days

print(alice)# src/main.py

def welcome():
    print("\n🔹 Welcome to the HR Automation Platform 🔹")
    print("This system is designed to blend technical precision with Zambian identity and communal growth.")
    print("Modules will include employee data, payroll, leave tracking, and compliance workflows.\n")

if __name__ == "__main__":
    welcome()# Entry point for HR automation platform
