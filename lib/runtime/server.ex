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
    new_accounts = Accounts.simulate_month(accounts, revenue)
    {:reply, new_accounts, new_accounts}
  end

  def handle_call(:calculate_expenses, _from, accounts) do
    {:reply, Expense.calculate_total_expenses(accounts.expenses), accounts}
  end

  def handle_call(:pay_expenses, _from, accounts) do
    IO.inspect(accounts.operating_expense, label: "Server")
    altered_accounts = Accounts.pay_expenses(accounts)
    {:reply, altered_accounts, altered_accounts}
  end

  def handle_call(:pay_owner, _from, accounts) do
    altered_accounts = Accounts.pay_owner(accounts)
    {:reply, altered_accounts, altered_accounts}
  end

  def handle_call(:check_threshold, _from, accounts) do
    {:reply, "checked", Accounts.check_thresholds(accounts)}
  end

end
