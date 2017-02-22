%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: ["lib/repo/tasks.ex"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120}
      ]
    }
  ]
}
