defmodule CashFlow do
  def new do
    {:ok, accounts } = CashFlow.Runtime.Server.start()
    accounts
  end

  def get_state(accounts) do
    :sys.get_state(accounts)
  end


  def set_expense_threshold(accounts, amount) do
    GenServer.call(accounts, {:set_expense_threshold, amount})
  end

  def add_expense(accounts, expense ) do
    GenServer.call(accounts, {:add_expense, expense})
    GenServer.call(accounts, {:set_expense_threshold, calculate_expense(accounts) + 10000})
  end

  def make_deposit(accounts, amount) do
    GenServer.call(accounts, {:make_deposit, amount})
  end

  def simulate_month(accounts, revenue) do
    GenServer.call(accounts, {:simulate_month, revenue})
  end

  def calculate_expense(accounts) do
    GenServer.call(accounts, :calculate_expenses)
  end

  def pay_expenses(accounts) do
    pay_owner(accounts)
    GenServer.call(accounts, :pay_expenses)
  end

  def pay_owner(accounts) do
    GenServer.call(accounts, :pay_owner)
  end

  def check_threshold(accounts) do
    GenServer.call(accounts, :check_threshold)
  end
end
