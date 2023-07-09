defmodule CashFlow.Runtime.Server do
  use GenServer
  alias CashFlow.Impl.Accounts
  alias CashFlow.Impl.Expense

  def start do
    GenServer.start(__MODULE__, nil)
  end
  def init(_) do
    {:ok, Accounts.new() }
  end

  def handle_call({:set_expense_threshold, amount}, _from, accounts) do
    new_accounts = Accounts.set_expense_threshold(accounts, amount)
    {:reply, new_accounts, new_accounts }
  end

  def handle_call({:add_expense, expense}, _from, accounts) do
    new_expense = Expense.new(expense)
    new_accounts = Accounts.add_expense(accounts, new_expense)
    {:reply, new_accounts, new_accounts}
  end

  def handle_call({:make_deposit, amount}, _from, accounts) do
    new_accounts = Accounts.make_deposit(accounts, amount)
    {:reply, new_accounts, new_accounts}
  end

  def handle_call({:simulate_month, revenue}, _from, accounts) do
    new_accounts = Accounts.simulate_month(accounts, revenue, Enum.reduce(accounts.expenses, 0, fn x, acc -> x.amount + acc end))
    {:reply, new_accounts, new_accounts}
  end

  def handle_call(:calculate_expenses, _from, accounts) do
    {:reply, Expense.calculate_total_expenses(accounts.expenses), accounts}
  end

end
