%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "www/"],
        excluded: ["lib/db/tasks.ex"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120}
      ]
    }
  ]
}
