import EctoEnum

# TODO: get rid off Ecto.Enum
# loans
defenum API.Repo.Enums.TransferStatuses,
  :transfer_status, ["authentication", "completed", "processing", "declined", "error"]

defenum API.Repo.Enums.ClaimStatuses,
  :transfer_status, ["authentication", "completed", "processing", "declined"]

defenum API.Repo.Enums.AuthTypes,
  :auth_type, ["3d-secure", "lookup-code"]

defenum API.Repo.Enums.AccountCredential,
  :account_credential, ["card", "card-number", "card-token", "external-credential"]
