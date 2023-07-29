defmodule CashFlow.Runtime.Application do

  @super_name CashflowStarter
  @registry_name CashflowRegistry

  def start(_type, _args) do
    supervisor_spec = [
      { DynamicSupervisor, strategy: :one_for_one, name: @super_name },
      {Registry, [keys: :unique, name: @registry_name]}
    ]

    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
  end

  def start_cashflow(name) do
    DynamicSupervisor.start_child(@super_name, {CashFlow.Runtime.Server, name})
  end
end
